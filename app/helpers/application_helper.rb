# -*- encoding : utf-8 -*-
module ApplicationHelper

def folderNameConcatenado(folder, name  = '')
return name if !name.blank?
miname = folder.name
miname = t("audiobox_view.root_name")  if folder.is_root?
return miname if folder.description.nil? || folder.description.blank?
	miname =  "#{folder.name}.- #{folder.description}"
	miname =  folder.description if folder.tipo == BOOK_PREFIX
	truncate(miname , :length => 50, :separator => ' ').html_safe
end


def breadcrumbs_gen_select(folder, id = 0, p_id = 0, breadcrumbs = '')
  if current_user.can_read(folder)
  selecionado = p_id == folder.id ? 'selected="true"' : ""
    breadcrumbs = %Q[#{breadcrumbs}\n<option value="#{folder.id}" #{selecionado}>#{truncate(folder.nameConcatenado, :length => 25, :separator => ' ')}</option>] if folder.id != id
  end
  folder.children.each do |f|
    breadcrumbs = breadcrumbs_gen_select(f, id, p_id, breadcrumbs)
    end
    breadcrumbs.html_safe
  end

def buscaRootBook(folder)
book_folder = folder
folder.ancestors.each do |ancestor_folder|
	book_folder = ancestor_folder if ancestor_folder.tipo == BOOK_PREFIX
end
book_folder
end

def ie?
    request.user_agent.nil? ? false : request.user_agent.index('MSIE') != nil
  end


# Translates a message.
  # Requires a @translations instance variable of type Hash and
  # following format:
  # translations = {
  #   caption => translation,
  #   caption => translation,
  #     ...
  #}
  def translate_single_message(caption)
    if @translations
      msgRegExp = /__MSG_\w+__/
      mr = msgRegExp.match(caption)
      if mr && mr.length > 0
        s = mr.pre_match
        extracted = extract_single_message(mr[0])
        s << (@translations ? (@translations[extracted] ? @translations[extracted] : extracted) : extracted)
        s << translate_single_message(mr.post_match)
        return s
      else
        return caption
      end
    else
      return caption
    end
  end

  def extract_single_message(caption)
    caption.gsub(/__MSG_/, '').gsub(/__$/, '')
  end

  def flash_tag(tag, fade = true)
    #flash[tag] ? content_tag(:div, flash[tag], :id => tag.to_s) + (fade ? javascript_tag(visual_effect(:fade, tag.to_s, :duration => 3, :delay => 1)) : ''): ''
    flash_message(flash[tag], tag,  fade)
  end

  def flash_message(msg, tag = :notice,  fade = true)
    msg ? content_tag(:div, msg, :id => tag.to_s, :class => 'info') + (fade ? javascript_tag(visual_effect(:fade, tag.to_s, :duration => 3, :delay => 1)) : ''): ''
  end
end

