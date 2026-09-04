RSpec.describe TableHelper, type: :helper do
  describe "#sorter_direction" do
    it "returns desc when the direction param is desc" do
      allow(helper).to receive(:params).and_return({ user_sort_direction: "desc" })

      expect(helper.sorter_direction(:user_sort_direction)).to eq("desc")
    end

    it "defaults to asc when the direction param is missing or not desc" do
      allow(helper).to receive(:params).and_return({})
      expect(helper.sorter_direction(:user_sort_direction)).to eq("asc")

      allow(helper).to receive(:params).and_return({ user_sort_direction: "asc" })
      expect(helper.sorter_direction(:user_sort_direction)).to eq("asc")
    end
  end

  describe "#target_direction" do
    it "returns desc when the direction param is asc" do
      allow(helper).to receive(:params).and_return({ user_sort_direction: "asc" })

      expect(helper.target_direction(:user_sort_direction)).to eq("desc")
    end

    it "returns asc when the direction param is desc" do
      allow(helper).to receive(:params).and_return({ user_sort_direction: "desc" })

      expect(helper.target_direction(:user_sort_direction)).to eq("asc")
    end
  end

  describe "#sorter_column?" do
    it "defaults to the default column when the sort column param is missing" do
      allow(helper).to receive(:params).and_return({})

      expect(helper.sorter_column?(:user_sort_column, "name", "name")).to be(true)
      expect(helper.sorter_column?(:user_sort_column, "email", "name")).to be(false)
    end

    it "returns true only for the current sort column when present" do
      allow(helper).to receive(:params).and_return({ user_sort_column: "email" })

      expect(helper.sorter_column?(:user_sort_column, "email", "name")).to be(true)
      expect(helper.sorter_column?(:user_sort_column, "name", "name")).to be(false)
    end
  end

  describe "#aria_sort" do
    it "returns ascending for the active column when sorted asc" do
      allow(helper).to receive(:params).and_return({ user_sort_column: "email", user_sort_direction: "asc" })

      expect(helper.aria_sort(:user_sort_direction, :user_sort_column, "email", "name")).to eq("ascending")
    end

    it "returns descending for the active column when sorted desc" do
      allow(helper).to receive(:params).and_return({ user_sort_column: "email", user_sort_direction: "desc" })

      expect(helper.aria_sort(:user_sort_direction, :user_sort_column, "email", "name")).to eq("descending")
    end

    it "returns none for inactive columns" do
      allow(helper).to receive(:params).and_return({ user_sort_column: "name", user_sort_direction: "asc" })

      expect(helper.aria_sort(:user_sort_direction, :user_sort_column, "email", "name")).to eq("none")
    end
  end

  describe "#sorter_path" do
    it "toggles direction and preserves existing query params" do
      allow(helper).to receive(:params).and_return({ user_sort_direction: "asc" })

      path = helper.sorter_path("/users?foo=bar", :user_sort_direction, :user_sort_column, "email")
      query = Addressable::URI.parse(path).query_values

      expect(query).to eq(
        "foo" => "bar",
        "user_sort_column" => "email",
        "user_sort_direction" => "desc",
      )
    end
  end

  describe "#sorter_link" do
    it "builds a sortable link with expected attributes" do
      allow(helper).to receive_messages(params: { sort_direction: "asc" }, sorter_direction: "asc")

      link = helper.sorter_link(
        path: "/users",
        direction_key: :user_sort_direction,
        column_key: :user_sort_column,
        column: "email",
      ) { "Email" }

      expect(link).to have_link("Email", href: "/users?user_sort_column=email&user_sort_direction=desc")
      expect(link).to have_css("a#email.app-no-wrap.govuk-link--no-visited-state.govuk-link--no-underline[aria-label='Sort email descending']")
    end
  end

  describe "#sorter_header" do
    before do
      allow(helper).to receive(:sorter_direction).and_return("asc")
      allow(helper).to receive(:render) do |partial|
        {
          "shared/up_icon" => "[up]",
          "shared/down_icon" => "[down]",
          "shared/updown_icon" => "[updown]",
        }.fetch(partial)
      end
    end

    it "shows the active direction icon for the current sort column" do
      allow(helper).to receive(:params).and_return({
        user_sort_column: "email",
        user_sort_direction: "asc",
      })

      header = helper.sorter_header(
        path: "/users",
        direction_key: :user_sort_direction,
        column_key: :user_sort_column,
        column: "email",
        label: "Email",
        default_sort_column: "name",
      )

      expect(header).to have_css("th.govuk-table__header[scope='col'][aria-sort='ascending']")
      expect(header).to include("[up]")
      expect(header).not_to include("[updown]")
    end

    it "shows the neutral icon for non-active columns" do
      allow(helper).to receive(:params).and_return({
        user_sort_column: "name",
        user_sort_direction: "asc",
      })

      header = helper.sorter_header(
        path: "/users",
        direction_key: :user_sort_direction,
        column_key: :user_sort_column,
        column: "email",
        label: "Email",
        default_sort_column: "name",
      )

      expect(header).to have_css("th.govuk-table__header[scope='col'][aria-sort='none']")
      expect(header).to include("[updown]")
      expect(header).not_to include("[up]")
    end
  end
end
