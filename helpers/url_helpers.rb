module UrlHelpers
  def repository_url(repo)
    "/#{repo.name}"
  end
  def commit_url(commit)
    "/#{commit.repository.name}/#{commit.commit_hash}"
  end
end