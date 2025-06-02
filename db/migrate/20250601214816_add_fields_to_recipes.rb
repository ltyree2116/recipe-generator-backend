class AddFieldsToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :tags, :string
    add_column :recipes, :user_preferences, :text
    add_column :recipes, :ai_generated, :boolean
  end
end
