def my_bad_indicator
    commits = Commit.mybad(current_user).size
    if commits > 0
        "<span class=\"round  label alert\">#{commits}</span>"
    end
end
