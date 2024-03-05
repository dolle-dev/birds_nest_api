require 'rails_helper'

RSpec.describe Node, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:node)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:parent).class_name('Node').optional }
    it { is_expected.to have_many(:birds).class_name('Node').with_foreign_key('parent_id').dependent(:destroy) }
  end

  describe ".lowest_common_ancestor" do
    let!(:root) { create(:node) }
    let!(:child1) { create(:node, parent: root) }
    let!(:child2) { create(:node, parent: root) }
    let!(:grandchild) { create(:node, parent: child1) }

    context "when nodes are the same" do
      it "returns the node itself as its own ancestor" do
        root_id, lca_id, depth = Node.lowest_common_ancestor(root.id, root.id)
        expect([root_id, lca_id, depth]).to eq([root.id, root.id, 1])
      end
    end

    context "when nodes have a common ancestor" do
      it "returns the lowest common ancestor" do
        root_id, lca_id, depth = Node.lowest_common_ancestor(child1.id, child2.id)
        expect([root_id, lca_id, depth]).to eq([root.id, root.id, 1])
      end
    end

    context "when one node is an ancestor of the other" do
      it "returns the ancestor node" do
        root_id, lca_id, depth = Node.lowest_common_ancestor(child1.id, grandchild.id)
        expect([root_id, lca_id, depth]).to eq([root.id, child1.id, 2])
      end
    end

    context 'when one of the nodes is the root' do
      let!(:root) { create(:node) }
      let!(:child) { create(:node, parent: root) }

      it 'returns the root as the common ancestor' do
        lca = Node.lowest_common_ancestor(root.id, child.id)
        expect(lca).to eq([root.id, root.id, 1])
      end
    end

    context 'when nodes are siblings' do
      let!(:parent) { create(:node) }
      let!(:sibling1) { create(:node, parent: parent) }
      let!(:sibling2) { create(:node, parent: parent) }

      it 'returns the parent as the common ancestor' do
        lca = Node.lowest_common_ancestor(sibling1.id, sibling2.id)
        expect(lca).to eq([parent.id, parent.id, 1])
      end
    end

    context 'when nodes are in separate branches without a common ancestor' do
      let!(:branch1) { create(:node) }
      let!(:branch2) { create(:node) }

      it 'returns nil for all values' do
        lca = Node.lowest_common_ancestor(branch1.id, branch2.id)
        expect(lca).to eq([nil, nil, nil])
      end
    end
  end

  describe '#update_ancestors_cache' do
    let!(:parent) { create(:node) }
    let!(:child) { create(:node, parent: parent) }

    it 'updates the ancestors_cache of the child when the parent changes' do
      new_parent = create(:node)
      parent.update(parent: new_parent)
      child.reload
      expect(child.ancestors_cache).to include(new_parent.id)
    end
  end
end
