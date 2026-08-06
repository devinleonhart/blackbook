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

  describe "#resize_to_limit_for" do
    it "passes an integer through as the width limit" do
      expect(helper.send(:resize_to_limit_for, 300)).to eq([300, nil])
    end

    it "uses width and height from an array" do
      expect(helper.send(:resize_to_limit_for, [200, 400])).to eq([200, 400])
    end

    it "defaults width to 1000 when the array has no width" do
      expect(helper.send(:resize_to_limit_for, [nil, 400])).to eq([1000, 400])
    end

    it "defaults to [1000, nil] for an unrecognized size" do
      expect(helper.send(:resize_to_limit_for, "huge")).to eq([1000, nil])
    end
  end

  describe "#safe_url_for" do
    it "returns the generated url when successful" do
      allow(helper).to receive(:url_for).and_return("/ok.png")
      expect(helper.send(:safe_url_for, double)).to eq("/ok.png")
    end

    it "logs and returns nil when url_for raises" do
      allow(helper).to receive(:url_for).and_raise(StandardError.new("boom"))
      expect(helper.send(:safe_url_for, double)).to be_nil
    end
  end
end
