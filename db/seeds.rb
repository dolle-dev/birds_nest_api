require 'csv'

csv_file_path = Rails.root.join('db/data', 'nodes.csv')

# Assuming Node model is already cleared out
Node.delete_all

# First, create all nodes without parents due to ensure foregin key constraints
node_records = {}
CSV.foreach(csv_file_path, headers: true) do |row|
  node = Node.create!(id: row['id'])
  node_records[row['id']] = node
end

# Then, assign parents now that all nodes exist
CSV.foreach(csv_file_path, headers: true) do |row|
  next if row['parent_id'].blank?
  
  node = node_records[row['id']]
  parent_node = node_records[row['parent_id']]
  if parent_node
    node.update(parent: parent_node)
  else
    puts "Parent node #{row['parent_id']} for node #{row['id']} not found."
  end
end

puts "Seeded #{Node.count} nodes from the CSV file."
