module TutorialsHelper

  # tutorial image
  def tutorial_image(image_path)
    return link_to(image_tag(image_path), asset_path(image_path), class: 'tutorial-image', target: '_blank')
  end

end
