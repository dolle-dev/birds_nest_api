class NodesController < ApplicationController
  before_action :validate_params, only: [:lowest_common_ancestor]
  before_action :validate_node_ids, only: [:birds]

  def lowest_common_ancestor
    root_id, lca_id, depth = Node.lowest_common_ancestor(params[:node1_id], params[:node2_id])

    render json: {
      root_id: root_id,
      lowest_common_ancestor: lca_id,
      depth: depth
    }
  end

  def birds
    render json: { birds: Node.birds_for_nodes(params[:node_ids].map(&:to_i)) }
  end

  private

  def validate_params
    unless params[:node1_id] && params[:node2_id]
      render json: { error: 'Both node1_id and node2_id are required.' }, status: :bad_request
    end
  end

  def validate_node_ids
    if params[:node_ids].blank?
      render json: { error: 'node_ids parameter is required.' }, status: :bad_request
    end
  end
end
