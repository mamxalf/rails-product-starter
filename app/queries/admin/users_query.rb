module Admin
  class UsersQuery
    def initialize(search: nil, role: nil, verification: nil, status: nil, sort: nil)
      @search = search.to_s.strip
      @role = role.to_s
      @verification = verification.to_s
      @status = status.to_s
      @sort = sort.to_s
    end

    def relation
      users = User.with_attached_avatar.includes(:sessions)
      users = users.where("name ILIKE :query OR email_address ILIKE :query", query: "%#{User.sanitize_sql_like(@search)}%") if @search.present?
      users = users.where(role: @role) if User.roles.key?(@role)
      users = users.where(email_verified_at: nil) if @verification == "unverified"
      users = users.where.not(email_verified_at: nil) if @verification == "verified"
      users = users.where(suspended_at: nil) if @status == "active"
      users = users.where.not(suspended_at: nil) if @status == "suspended"
      users.order(created_at: @sort == "oldest" ? :asc : :desc)
    end
  end
end
