# -*- encoding : utf-8 -*-
module LibrariesHelper

def breadcrumbs_gen_book(folder, breadcrumbs = '')
  if current_user.can_read(folder)
  nivel = calculaNivel(folder)
  section = breadcrumbs == "" ? "titol" : "section"
  opcions = breadcrumbs == "" ? "#{t('audiobox_view.anar_index')}" : "#{t('audiobox_view.anar_seccio')}"
    breadcrumbs = %Q[#{breadcrumbs}\n<section class="#{section}">\n<h#{nivel} role="heading" aria-level="#{nivel}">#{folder.nameConcatenado}</h#{nivel}>#{link_to( folder, :class => 'boto') { "#{opcions} <span class='amagar'>#{folder.nameConcatenado}</span>".html_safe}}]
      dato = ""
      tot_files = folder.user_files.size
       contador  = 1
    folder.user_files.each do |file|
    	ultim = tot_files == contador ? %q[ class="ultim"] : ""
    	abre_en = is_val_extFile?(file.attachment_file_name) ? {'class' => 'track'} : { 'target' => 'new_file'}
    	dato = "#{dato}\n<li#{ultim}>#{link_to(file.nameConcatenado, "http://#{HOST_DV}#{file_path(file)}", abre_en   )}</li>"
    	contador += 1

    	dato2 = ""
    	tot_coment = file.coments.size
       contador2  = 1
    file.coments.each do |comentario|
    	ultim = tot_coment == contador2 ? %q[ class="ultim"] : ""
    	texte = "comentario: #{truncate(comentario.comentario)} #{comentario.user.name}"
    	dato2 = "#{dato2}\n<li#{ultim}>#{link_to(texte, coment_path(comentario), :remote => @rem_true)}</li>"
    	contador2 += 1
    end
    dato = "#{dato}\n<ul  class='decorada subllista'>#{dato2}\n</ul>" unless dato2.blank?
    end
    breadcrumbs = "#{breadcrumbs}\n<ul class='decorada'>#{dato}\n</ul>" unless dato.blank?
    breadcrumbs = "#{breadcrumbs}\n</section>" if section == "titol"
  end
  folder.children.each do |f|
    breadcrumbs = breadcrumbs_gen_book(f, breadcrumbs)
    end
    breadcrumbs = "#{breadcrumbs}\n</section>" if section == "section"
    breadcrumbs.html_safe
  end

def sanitize_link_cgi(cgi, campus_translator)
    link = "#"
    if cgi

#for the preference options, we don't transations in the links
      if cgi.index(".uoc.edu")
        link = campus_translator.translate_text(cgi,"a" )
        else
        link = cgi
      end
      end
      link
      end

def calculaNivel(folder)
contador = 1
folder.ancestors.each do |ancestor_folder|
	contador = contador + 1 unless  ancestor_folder.is_root?   #tipo == "capitol" || BOOK_PREFIX
end
contador
end
end
