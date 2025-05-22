require 'hitoku'
require 'todoist_cms'

def random_count(from, to, step)
  from.step(to, step).to_a.sample
end

missions = [
  "GitHubに草を生やす",
  "PCデスクを綺麗にする",
  "部屋の掃除（#{random_count(10, 30, 5)}分）",
  "読書（#{random_count(10, 20, 5)}分）",
  "#{random_count(1500, 3000, 100)}歩以上歩く",
  "腕立て（#{random_count(10, 20, 5)}回）",
  "スクワット（#{random_count(10, 20, 5)}回）"
]

client = TodoistCMS::Client.new(Hitoku.todoist_api_token)
project = client.project(2354178106)

project.truncate
missions.sample(3).each do |mission|
  project.create_item(mission)
end
