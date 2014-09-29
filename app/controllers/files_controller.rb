# -*- encoding : utf-8 -*-
require 'mime/types'
require 'taglib'
begin
  require 'zip/zip'
rescue LoadError
puts "gema zip no instalada"
end


class FilesController < ApplicationController
  wrap_parameters false

  before_filter :require_existing_file, :only => [:show, :edit, :update, :destroy]
  before_filter :require_existing_parent_folder, :only => [:new, :create,:index]
  before_filter :require_existing_folder, :only => [:daisy, :zip,:update_multiple]

  before_filter :require_create_permission, :only => [:new, :create]
  before_filter :require_read_permission, :only => :show
  before_filter :require_update_permission, :only => [:edit, :update]
  before_filter :require_delete_permission, :only => :destroy

  layout "audiobox"

  def index
    @files = @parent_folder.user_files.all

    respond_to do |format|
      format.json { render :json => @files.collect { |p| p.to_jq_upload }.to_json }
    end
  end


  # GET /files/:id
  # Note: @file and @folder are set in require_existing_file
  def show
  log "descargando ficheros #{@file.attachment.path} -- #{@file.attachment.url} -- #{MIME::Types.type_for(@file.attachment_file_name).to_s}",2, "audioBox"
  modo = params["modo"] == 'down' ? 'attachment' : 'inline'
      send_file @file.attachment.path, :filename => @file.attachment_file_name, :disposition => modo, :type => MIME::Types.type_for(@file.attachment_file_name)[0]
  end

  # GET /folders/:id/files/new
  # Note: @parent_folder is set in require_existing_parent_folder
  def new
    if @current_user.is_box?
      @file = @parent_folder.user_files.build
      @b_folder =  @parent_folder
      @file .orden = calculaOrden(@parent_folder)
      @form_clasic  = true
      @form_clasic  = false if params[:clasic] == false
      @title = t "library_view.new"
      @breadcrumbs = t("audiobox_view.uploadFile") unless @rem_true
      respond_to do |format|
        format.html # new.html.erb
        #format.json { render :json => [@parent_folder, @file].to_json }
        format.js
      end
    else
      redirect_to folder_url(Folder.root(current_user.id))
    end
  end

  # POST /folders/:id/files
  # Note: @parent_folder is set in require_existing_parent_folder
  def create
    if request.method == "POST" && !params[:user_file].nil?
    if !params["parent_id"].nil? && @parent_folder.id != params["parent_id"]
    @parent_folder = Folder.find(params["parent_id"])
  end
    if params['call_clasic'].nil? || params['overwrite'] == "1"
    @file = UserFile.yaSincronizado(params[:user_file][:attachment].original_filename, @parent_folder)
      @file = @parent_folder.user_files.build(params[:user_file]) if  @file.nil?
      else
      @file = @parent_folder.user_files.build(params[:user_file])
    end
      @file.attachment_file_name = params[:user_file][:attachment].original_filename
      @file.attachment.cnamed = params[:user_file][:attachment].original_filename
      @file.user_id = @current_user.id
      @file.tipo = @parent_folder.tipo
      @file.attachment.file_tipo = @parent_folder.tipo
      @file .orden = calculaOrden(@parent_folder)

      begin
      @file.save!
        log "audiobox subido fichero audiobox: #{ [@file.to_jq_upload].to_json} - #{@file.inspect}"
        if !params['call_clasic'].nil?
          redirect_to folder_url(@parent_folder), :notice => t(:msg_ok_file_created) and return
        else
          respond_to do |format|
            format.html {                                         #(html response is for browsers using iframe sollution)
              render :json => [@file.to_jq_upload].to_json,
              :content_type => 'text/html',
              :layout => false
            }
            format.json { render :json => [@file.to_jq_upload].to_json }
          end
        end
      rescue Exception => e
        log "audiobox subido con error #{@file.errors.messages} fichero audiobox: #{@file.inspect}  -#{params[:user_file].inspect} ", 2
        respond_to do |format|
        if !params['call_clasic'].nil?
          @form_clasic  = true
          @form_clasic = false if params[:clasic] == false
          format.html { render :action => 'new' }
        else
                    format.html {                                         #(html response is for browsers using iframe sollution)
              render :json => [@file.to_jq_upload.merge({ :error => "custom_failure" })].to_json,
              :content_type => 'text/html',
              :layout => false
            }
          format.json { render :json => [ @file.to_jq_upload.merge({ :error => "custom_failure" }) ].to_json }
        end
        end
      end

    else
      # display a multipart file field form
      @file = @parent_folder.user_files.build
      respond_to do |format|
      if !params['call_clasic'].nil?
          @form_clasic  = true
          @form_clasic  = false if params[:clasic] == false
          format.html {render :action => 'new'}
        else
                    format.html {                                         #(html response is for browsers using iframe sollution)
              render :json => [@file.to_jq_upload.merge({ :error => "custom_failure: #{@file.errors.messages}" })].to_json,
              :content_type => 'text/html',
              :layout => false
            }
          format.json { render :json => [ @file.to_jq_upload.merge({ :error => "custom_failure: #{@file.errors.messages}" }) ].to_json }
        end
        end
  end
  end

  # GET /files/:id/edit
  # Note: @file and @folder are set in require_existing_file
  def edit
  @title = t "library_view.edit"
  @mi_action = 'edit'
  @breadcrumbs = t("audiobox_view.renameFile") unless @rem_true
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  # PUT /files/:id
  # Note: @file and @folder are set in require_existing_file
  def update
  @file.folder_id = params["parent_id"] if !params["parent_id"].nil? && @file.folder_id != params["parent_id"]
      if @file.update_attributes(params[:user_file])
        flash[:notice] = t(:msg_file_ok_update)
        redirect_to folder_url(@folder)
      else
      respond_to do |format|
              flash[:notice] = t(:msg_bad_save)
      @mi_action = 'edit'
        format.html { render :action => "edit" }
        #format.json { render :json => @folder.errors, :status => :unprocessable_entity }
        format.js { render :action => "edit" }
      end
      end
  end

  # DELETE /files/:id
  # Note: @file and @folder are set in require_existing_file
  def destroy
      @file.destroy
    redirect_to folder_url(@folder)
  end

  def update_multiple
    log "modificando multiple ficheros ",1, "uocBox"
    if @folder && !user_session[:my_params]["file"].nil?
	if !user_session[:my_params]["Elimina"].nil?
      user_session[:my_params]["file"].each do |param|
        log "parametres folder: #{param[0]} - valor: #{param[1]}", 0, "uocBox"
        id = param[0]
        if !id.nil?
          valor = param[1]["is_preferido"] == '1'
          valor = true if user_session[:my_params]["checkbox_all"] ==  "1"
          @file= UserFile.find(id)
          if @file && valor
            log "canviado estado file: #{id} - #{@file.attachment_file_name} - valor: #{valor}",1, "uocBox"

              @file.destroy

                      end
        end
      end
    user_session[:my_params] = nil

    respond_to do |format|
      format.html { redirect_to folder_url(params[:id].nil? ? Folder.root(current_user.id) : params[:id]) }
    end

    else # si no es eliminar

image_list = []
user_session[:my_params]["file"].each do |param|
        log "parametres folder: #{param[0]} - valor: #{param[1]}", 0, "uocBox"
        id = param[0]
        if !id.nil?
          valor = param[1]["is_preferido"] == '1'
          valor = true if user_session[:my_params]["checkbox_all"] ==  "1"
          @file= UserFile.find(id)
          if @file && valor
            log "canviado estado file: #{id} - #{@file.attachment_file_name} - valor: #{valor}",1, "uocBox"
             image_list.append(@file)
           end
           end
           end

if !image_list.nil? && image_list.size > 0
download_zip(@folder, image_list)
else
respond_to do |format|
      format.html { redirect_to folder_url(params[:id].nil? ? Folder.root(current_user.id) : params[:id]) }
    end
    user_session[:my_params] = nil
    end
    end
    else # si nada seleccionado
        respond_to do |format|
      format.html { redirect_to folder_url(params[:id].nil? ? Folder.root(current_user.id) : params[:id]) }
    end
    end
  end

def zip
    log "exportando ficheros a zip",1, "uocBox"
    image_list = nil
    if @folder
    image_list = mp3ToZip(@folder)
  end

    if !image_list.nil? && image_list.size > 0
    download_zip(@folder, image_list, "zip")
    else
    respond_to do |format|
    	      format.html { redirect_to folder_url(params[:id].nil? ? Folder.root(current_user.id) : params[:id]) }
    end
    end
    end

def daisy
    log "exportando ficheros a daisy",1, "uocBox"
    image_list = nil
    if @folder
    image_list = mp3ToZip(@folder, 'daisy')
  end

    if !image_list.nil? && image_list.size > 0
    download_zip(@folder, image_list, "daisy")
    else
    respond_to do |format|
    	      format.html { redirect_to folder_url(params[:id].nil? ? Folder.root(current_user.id) : params[:id]) }
    end
    end
    end

  private

 def download_zip(folder, image_list, prefijo = nil)
    if !image_list.blank?
      file_name = "export_#{folder.name}_#{folder.user.campuslogin}.zip"
      contador = 0
      @tot_duracion = 0
      @folder = folder

      t = Tempfile.new("my-temp-filename-#{Time.now}")
      Zip::ZipOutputStream.open(t.path) do |z|

      	image_list.each do |file|
      		log "#{file.inspect}"
        	title = file.attachment_file_name
        	str_contador = "%04d" % contador
          title = "#{str_contador}_#{title}" if !prefijo.nil?
          z.put_next_entry(title)
      z.print IO.read(file.attachment.path)

      if prefijo == "daisy"
      z.put_next_entry("#{str_contador}.smil")
      z.print crea_smil(@folder, file, title)
    end

      contador += 1
        end

        if prefijo == "daisy"
      z.put_next_entry("ncc.html")
      z.print crea_ncc(@folder, contador)
    end

      end
      send_file t.path, :type => 'application/zip',
                             :disposition => 'attachment',
                             :filename => file_name
      t.close
      return true
    end
  end

def calculaOrden(folder)
contador = folder.user_files.size
contador
end

  def require_existing_file
  begin
    @file = UserFile.find(params[:id])
    @folder = @file.folder
        if @folder.user_id != current_user.id then
    if !has_share_access?(@folder )
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id))
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end

def gen_ncc_file(folder, contador = 0, breadcrumbs = '', init_nivel = 0)
  if current_user.can_read(folder)
  nivel = calculaNivel(folder, init_nivel)
  if contador == 0 && nivel > 1
  init_nivel  = nivel -1
  nivel = 1
end
nivel_virtual = nivel + 1
      dato = ""
    folder.user_files.each do |file|
    	if is_val_extFile?(file.attachment_file_name, ['mp3','wab'])
    	str_contador = "%04d" % contador
    	if dato.blank?
    	str_clas = contador == 0 ? "class=\"title\" id=\"heading_#{nivel}_title\"" : "class=\"section\" id=\"heading_#{nivel}_#{file.id}i\""
    	dato = "<h#{nivel} #{str_clas}><a href=\"#{str_contador}.smil#bookid_#{file.id}\">#{folder.nameConcatenado}</a></h#{nivel}>\n"
    	else
    	if !folder.has_children?
    	str_clas = "class=\"section\" id=\"heading_#{nivel_virtual}_#{file.id}ii\""
    	 dato = "#{dato}<h#{nivel_virtual} #{str_clas}><a href=\"#{str_contador}.smil#bookid_#{file.id}\">#{file.nameConcatenado}</a></h#{nivel_virtual  }>\n"
    	else
    	dato = "#{dato}<span class=\"page-normal\" id=\"page_#{nivel}_#{file.id}s\"><a href='#{str_contador}.smil#bookid_#{file.id}'>#{file.nameConcatenado}</a></span>\n"
    end
    end
    	contador  += 1
    end
    end
    breadcrumbs = "#{breadcrumbs}\n#{dato}" unless dato.blank?
  end
  folder.children.each do |f|
    breadcrumbs = gen_ncc_file(f, contador , breadcrumbs, init_nivel)
    end
    breadcrumbs.html_safe
  end


def calculaNivel(folder, init_nivel = 0)
contador = 1
folder.ancestors.each do |ancestor_folder|
	contador = contador + 1 unless  ancestor_folder.is_root?
end
contador -= init_nivel  if init_nivel  > 0
contador
end

def crea_smil(folder, file, title)
duracion  = getAudioPropertis(file.attachment.path)
@tot_duracion  += duracion
smil = <<-RESPONSE
<?xml version="1.0" encoding="iso-8859-1"?>
<smil>
<head>
<meta content="Daisy 2.02" name="dc:format"/>
<layout>
<region id="txt-view"/>
</layout>
</head>
<body>
<seq dur="#{duracion}s">
<par endsync="last">
<text id="bookid_#{file.id}" src="modul_1.html#1_#{file.id}"/>
<seq>
<audio id="audio1_#{file.id}" clip-end="npt=#{duracion}s" clip-begin="npt=0s" src="#{title}"/>
</seq>
</par>
</seq>
</body>
</smil>
      RESPONSE
      smil
end

def crea_ncc(folder, num_items)
ncc = <<-RESPONSE
      <?xml version="1.0" encoding="#{folder.description.encoding}"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-type" content="text/html; charset=#{folder.description.encoding}" />
<title>#{folder.description}</title>
    <meta name="dc:title" content="#{folder.description}" />
    <meta name="dc:creator" content="#{folder.user.name}" />
<meta content="Daisy 2.02" name="dc:format"/>
<meta content="UOC" name="dc:publisher"/>
<meta content="DTB-PID_#{folder.id}" name="dc:identifier"/>
<meta content="PID_#{folder.id}" name="dc:source"/>
<meta content="#{Time.now}" name="dc:date"/>
<meta content="ca" name="dc:language"/>
<meta content="0" name="ncc:footnotes"/>
<meta content="0" name="ncc:pageFront"/>
<meta content="0" name="ncc:pageNormal"/>
<meta content="0" name="ncc:pageSpecial"/>
<meta content="0" name="ncc:prodNotes"/>
<meta content="0" name="ncc:sidebars"/>
<meta content="1 of 1" name="ncc:setInfo"/>
<meta content="0" name="ncc:maxPageNormal"/>
<meta content="Editorial" name="ncc:sourcePublisher"/>
<meta content="Universitat Oberta de Catalunya" name="ncc:producer"/>
<meta content="#{num_items}" name="ncc:tocItems"/>
<meta scheme="hh:mm:ss" content="#{@tot_duracion}" name="ncc:totalTime"/>
<meta content="Loquendo 6.5" name="ncc:narrator"/>
<meta content="iso-8859-1" name="ncc:charset"/>
</head>
<body>
#{gen_ncc_file(folder)}
      </body>
</html>
      RESPONSE
      ncc
end


def getAudioPropertis(miFile)
duracion = 0
   TagLib::FileRef.open(miFile) do |file|
       unless file.null?
         prop = file.audio_properties
  duracion  = prop.length
  #       puts prop.bitrate
  log "audio propiedades #{prop.length}  - #{prop.inspect}"
       end
     end
     duracion
end

  def require_existing_folder
    begin
    @folder = Folder.find(params[:id])
    if @folder.user_id != current_user.id then
    if !has_share_access?(@folder )
    flash[:error] = t(:error_folder_permiso)
      redirect_to folder_url(Folder.root(current_user.id))
  end
  end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t(:error_folder_not_found)
    redirect_to folder_url(Folder.root(current_user.id))
  end
  end



end
