function delete_all_docker_images() {
    echo "Attempting to delete all Docker images..."
    # List all images, get their IDs, and attempt to remove them
    docker rmi $(docker images -q) -f

    # After removal, check if there are any remaining images and report
    remaining_images=$(docker images -q)
    if [ -z "$remaining_images" ]; then
        echo "All Docker images have been successfully removed."
    else
        echo "Some images could not be removed."
    fi
}
