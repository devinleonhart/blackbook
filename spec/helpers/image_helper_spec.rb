# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageHelper, type: :helper do
  describe "#generate_image_tag" do
    it "returns a placeholder when no attachment is present" do
      image = build_stubbed(:image)
      allow(image).to receive(:image_file).and_return(double(attached?: false))

      html = helper.generate_image_tag(image, 1000)
      expect(html).to include("Loading")
    end

    it "renders an <img> for a gif attachment" do
      image = build_stubbed(:image)
      file = double(attached?: true, filename: double(extension: "gif"))
      allow(image).to receive(:image_file).and_return(file)
      allow(helper).to receive(:safe_url_for).and_return("/fake.gif")

      html = helper.generate_image_tag(image, 1000)
      expect(html).to include("<img")
      expect(html).to include("src=\"/fake.gif\"")
    end

    it "rescues errors and returns an error placeholder" do
      image = build_stubbed(:image, id: 123)
      file = double(attached?: true, filename: double(extension: "jpg"))
      allow(image).to receive(:image_file).and_return(file)
      allow(file).to receive(:variant).and_raise(StandardError.new("boom"))

      html = helper.generate_image_tag(image, 1000)
      expect(html).to include("Image unavailable")
    end
  end
end
