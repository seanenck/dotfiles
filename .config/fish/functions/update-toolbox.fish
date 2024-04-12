function update-toolbox
    for tb in  (toolbox list -c | tail -n +2 | awk '{print $2}')
        echo "updating $tb..."
        if ! toolbox run -c "$tb" sudo dnf update -y
            echo "update failed"
        end
    end
end
