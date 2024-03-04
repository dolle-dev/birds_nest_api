class CreateNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :nodes do |t|
      t.references :parent, index: true, foreign_key: { to_table: :nodes }
      t.integer :ancestors_cache, array: true, default: []

      t.timestamps
    end

    add_index :nodes, :ancestors_cache, using: 'gin'
  end
end
