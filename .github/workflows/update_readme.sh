#!/bin/bash

# Directory where your wallpapers are located (change this if needed)
wallpapers_dir="."  # Change this if wallpapers are in a specific folder (e.g., "walls")
output_file="README.md"

# Automatically generate commit message for GitHub Actions
commit_msg="Auto-update README with new wallpapers"

# Function to generate the markdown table of wallpapers
generate_markdown() {
  local wallpapers=()
  local row_counter=0
  local row=""

  # Loop through all image files in the directory
  for image in "$wallpapers_dir"/*.{jpg,jpeg,png,gif}; do
    if [[ -f "$image" ]]; then
      filename=$(basename "$image")
      # Create the URL to the raw image in the repo
      image_url="https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/$filename"
      
      # Add the image to the markdown row (each row will have 4 columns)
      row="$row| ![${filename}](${image_url}) "

      # Increment row counter
      ((row_counter++))

      # If we have 4 columns, write the row and reset
      if [ $row_counter -eq 4 ]; then
        echo "$row|" >> "$output_file"
        row_counter=0
        row=""
      fi
    fi
  done

  # If there are leftover images in the row, fill the row with empty cells
  if [ $row_counter -ne 0 ]; then
    while [ $row_counter -lt 4 ]; do
      row="$row| "
      ((row_counter++))
    done
    echo "$row|" >> "$output_file"
  fi

  echo "Markdown table generated in $output_file"
}

# Prepare the README
echo "# Wallpapers Collection" > "$output_file"
echo "This is a collection of wallpapers. Click on the image to view the full-size version." >> "$output_file"
echo "" >> "$output_file"

# Add disclaimer
echo "### Disclaimer" >> "$output_file"
echo "" >> "$output_file"
echo "> **I do not claim ownership of any of the wallpapers in this repository.**" >> "$output_file"
echo "> These wallpapers were collected from various sources across the internet. I did not create them; I’m simply backing them up and sharing them for personal and community use. If you are the creator of any of these works and would like credit or removal, feel free to open an issue or contact me." >> "$output_file"
echo "" >> "$output_file"

# Add table header
echo "## Preview of Wallpapers" >> "$output_file"
echo "" >> "$output_file"
echo "| Wallpaper 1 | Wallpaper 2 | Wallpaper 3 | Wallpaper 4 |" >> "$output_file"
echo "|-------------|-------------|-------------|-------------|" >> "$output_file"

# Generate the markdown table with images
generate_markdown

# Force a commit even if the README hasn't changed (by modifying the commit timestamp)
touch "$output_file"

# Check if any new wallpapers have been added by checking the status
if git diff --exit-code --quiet; then
  echo "No changes to commit"
else
  # Stage changes to README.md if any new wallpapers were added
  git add README.md

  # Commit changes with a unique timestamp and message
  git commit --author="github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>" -m "$commit_msg - $(date +'%Y-%m-%d %H:%M:%S')"

  # Push the commit (no force-push needed)
  git push origin HEAD:main
fi
