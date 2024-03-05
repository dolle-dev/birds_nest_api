class Node < ApplicationRecord
  # Associations
  belongs_to :parent, class_name: 'Node', optional: true
  has_many :birds, class_name: 'Node', foreign_key: 'parent_id', dependent: :destroy

  # Callbacks
  after_create_commit :cache_ancestors_on_create
  before_save :cache_ancestors, if: :parent_id_changed?
  after_save :update_descendants_cache, if: :saved_change_to_parent_id?

  # Class methods
  class << self
    def lowest_common_ancestor(node1_id, node2_id)
      return handle_identical_node_ids(node1_id) if node1_id == node2_id

      node1, node2 = find_nodes_by_ids(node1_id, node2_id)
      
      return [nil, nil, nil] unless node1 && node2

      calculate_common_ancestors(node1.ancestors_cache.unshift(node1.id), node2.ancestors_cache.unshift(node2.id))
    end

    def birds_for_nodes(node_ids)
      where('ARRAY[:ids]::integer[] && ancestors_cache', ids: node_ids).distinct.pluck(:id)
    end
  end

  # Instance methods
  def update_ancestors_cache(visited_nodes = {})
    return if visited_nodes.key?(self.id)
  
    visited_nodes[self.id] = true
  
    cache_ancestors
    save(validate: false)
  
    birds.find_each { |bird| bird.update_ancestors_cache(visited_nodes) }
  end  

  private

  class << self
    def handle_identical_node_ids(node_id)
      node = find_by(id: node_id)
      root = node.ancestors_cache.last || node
      node ? [root.id, node.id, node.ancestors_cache.length + 1] : [nil, nil, nil]
    end

    def find_nodes_by_ids(node1_id, node2_id)
      [find_by(id: node1_id), find_by(id: node2_id)]
    end

    def calculate_common_ancestors(ancestors1, ancestors2)
      common_ancestors = ancestors1 & ancestors2

      return [nil, nil, nil] if common_ancestors.empty?

      [common_ancestors.last, common_ancestors.first, common_ancestors.length]
    end
  end

  def cache_ancestors(visited_nodes = {})
    self.ancestors_cache = []
    visited_nodes[self.id] = true
    current_node = self.parent

    while current_node && !visited_nodes[current_node.id]
      self.ancestors_cache << current_node.id
      visited_nodes[current_node.id] = true
      current_node = current_node.parent
    end
  end

  def cache_ancestors_on_create
    update_ancestors_cache
  end

  def update_descendants_cache
    birds.find_each(&:update_ancestors_cache)
  end
end

