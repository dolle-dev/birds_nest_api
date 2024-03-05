require 'rails_helper'

RSpec.describe NodesController, type: :controller do
  describe "GET #lowest_common_ancestor" do
    let!(:root) { create(:node) }
    let!(:child1) { create(:node, parent: root) }
    let!(:child2) { create(:node, parent: root) }

    context "with valid parameters" do
      before { get :lowest_common_ancestor, params: { node1_id: child1.id, node2_id: child2.id } }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the correct JSON response" do
        expect(JSON.parse(response.body)).to include("root_id", "lowest_common_ancestor", "depth")
      end
    end

    context "with missing parameters" do
      before { get :lowest_common_ancestor, params: {} }

      it "returns a bad request status" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "GET #birds" do
    let!(:nodes) { create_list(:node, 3) }

    context "with valid parameters" do
      before { get :birds, params: { node_ids: nodes.map(&:id) } }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "with missing parameters" do
      before { get :birds, params: {} }

      it "returns a bad request status" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
