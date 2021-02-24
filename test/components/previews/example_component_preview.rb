class ExampleComponentPreview < ViewComponent::Preview
  def default
    render(ExampleComponent.new)
  end
end
