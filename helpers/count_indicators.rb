def my_bad_indicator
    commits = Commit.mybad(current_user).size
    if commits > 0
        "<span class=\"round  label alert\">#{commits}</span>"
    end
end

def pending_review_indicator
    commits = Commit.pending_for_me(current_user).where({ :timestamp.gt => Time.now - 10.days }).size
    if commits > 0
        "<span class=\"round  label alert\">#{commits}</span>"
    end
end
