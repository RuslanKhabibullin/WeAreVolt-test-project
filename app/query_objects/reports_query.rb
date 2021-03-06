class ReportsQuery
  attr_reader :starts_at, :ends_at
  private :starts_at, :ends_at

  def initialize(starts_at, ends_at)
    @starts_at = starts_at
    @ends_at = ends_at
  end

  def all
    User.from(report_table_query.to_sql).order("posts_count + comments_count / 10 DESC")
  end

  private

  # rubocop:disable Metrics/AbcSize
  def report_table_query
    users
      .project(
        users[:id],
        users[:email],
        users[:nickname],
        relation_count_query(posts).as("posts_count"),
        relation_count_query(comments).as("comments_count")
      )
      .as(Arel.sql("users"))
  end

  def relation_count_query(relation)
    relation
      .where(relation[:author_id].eq(users[:id]))
      .where(relation[:published_at].in((starts_at..ends_at)))
      .project(relation[:id].count)
  end

  def posts
    @posts ||= Post.arel_table
  end

  def comments
    @comments ||= Comment.arel_table
  end

  def users
    @users ||= User.arel_table
  end
end
