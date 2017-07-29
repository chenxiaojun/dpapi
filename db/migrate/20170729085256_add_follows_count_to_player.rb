class AddFollowsCountToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :follows_count, :integer, comment: '该牌手的被关注数'
  end
end
