module TutorialsHelper

  # tutorial image
  def tutorial_image(image_path, style=nil)
    return link_to(image_tag(image_path), asset_path(image_path), class: 'tutorial-image', style: style, target: '_blank')
  end

end
