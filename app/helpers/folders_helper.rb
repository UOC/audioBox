# -*- encoding : utf-8 -*-
#require 'mime/types'
module FoldersHelper
  def breadcrumbs(folder, breadcrumbs = '')
  if current_user.can_read(folder.parent) || folder.parent.is_root? then
  	if  folder.parent.is_root? then
    breadcrumbs = "#{link_to( t("audiobox_view.root_name"), Folder.root(current_user.id), :class => 'primer' )  }<span class=\"amagar\"> &gt; </span>#{breadcrumbs}"
    else
    breadcrumbs = "#{link_to( folder.parent, :class => 'breadcrumb') { truncate(folder.parent.nameConcatenado, :length => 50, :separator => ' ')  }}<span class=\"amagar\"> &gt; </span>#{breadcrumbs}"
  end
  end
    breadcrumbs = breadcrumbs(folder.parent, breadcrumbs) unless folder.parent == Folder.root(folder.user_id)
    breadcrumbs.html_safe
  end

def getImagenFile(fileName)
#miFileExtension = MIME::Types.type_for(fileName).to_s
ext = getExtFile(fileName)
      list =MI_FILE_ESTENSIONS[ext]
                        return "file.png" if list.nil?
                        "icons/#{list}"
end

def getExtFile(fileName)
ext = fileName.chomp.downcase.gsub(/.*\./o, '')
ext
end


def breadcrumbs_gen_tree(folder, id, display_file = 0, breadcrumbs = '', name = '')
  if current_user.can_read(folder)
  section = breadcrumbs == "" ? "titol" : "section"
        dato = ""
        @all_folder_vacio  = false if folder.user_files.size > 0
      if display_file == 1
      tot_files = folder.user_files.size
    dato = %Q[<ul><li class="marcadors"><span class="#{tot_files > 0 ? "nous unic" : "cap unic nous"}"	title="archivos">#{tot_files}<span class='amagar'>Archivos</span></span></li></ul>]
end
  if folder.id == id
    breadcrumbs = %Q[#{breadcrumbs}\n<li class="#{section}"><span class='seleccionat'>#{image_tag('opcions-boto.png', :alt => t('audiobox_view.seleccionat'), :class => 'amagar') + "#{folderNameConcatenado(folder, name)}</span>".html_safe}#{dato}</li>]
    else
    breadcrumbs = %Q[#{breadcrumbs}\n<li class="#{section}">#{link_to( folder) {  "<span>#{folderNameConcatenado(folder, name)}</span>".html_safe}}#{dato}</li>]
  end
      dato = ""
      if display_file == 2
      tot_files = folder.user_files.size
       contador  = 1
    folder.user_files.each do |file|
    	ultim = tot_files == contador ? %q[ class="ultim"] : ""
    	abre_en = is_val_extFile?(file.attachment_file_name) ? {'class' => 'track'} : { 'target' => 'new_file'}
    	dato = "#{dato}\n<li#{ultim}>#{link_to(file.nameConcatenado, "http://#{HOST_DV}#{file_path(file)}", abre_en   )}</li>"
    	contador += 1
    end
    breadcrumbs = "#{breadcrumbs}\n<ul class='decorada'>#{dato}\n</ul>" unless dato.blank?
  end
  end
  breadcrumbs2 = nil
  cadena= "<ul>"
  folder.children.each do |f|
    breadcrumbs2 = breadcrumbs_gen_tree(f, id, display_file, "#{cadena}#{breadcrumbs2}")
    cadena = ""
    end
    breadcrumbs = "#{breadcrumbs}\n#{breadcrumbs2}\n</ul>" if !breadcrumbs2.nil?
    breadcrumbs.html_safe
  end

end
