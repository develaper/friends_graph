require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      User.create!(
        :friends => nil
      ),
      User.create!(
        :friends => nil
      )
    ])
  end

  it "renders a list of users" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
