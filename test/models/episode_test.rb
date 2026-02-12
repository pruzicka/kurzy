require "test_helper"

class EpisodeTest < ActiveSupport::TestCase
  test "valid episode" do
    episode = episodes(:one)
    assert episode.valid?
  end

  test "requires title" do
    episode = Episode.new(subscription_plan: subscription_plans(:one), position: 10)
    assert_not episode.valid?
    assert_includes episode.errors[:title], "can't be blank"
  end

  test "rejects invalid status" do
    episode = episodes(:one)
    episode.status = "bogus"
    assert_not episode.valid?
  end

  test "published scope" do
    episodes = Episode.published
    assert episodes.all? { |e| e.status == "published" }
  end

  test "ordered scope" do
    episodes = Episode.ordered
    positions = episodes.map(&:position)
    assert_equal positions.sort, positions
  end

  test "auto-assigns position on create" do
    plan = subscription_plans(:one)
    max_position = plan.episodes.maximum(:position) || 0
    episode = plan.episodes.create!(title: "New episode", status: "draft")
    assert_equal max_position + 1, episode.position
  end
end
