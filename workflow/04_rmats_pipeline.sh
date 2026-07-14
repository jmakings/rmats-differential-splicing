# Create session
tmux new-session -s rmats-pipeline -d

# Run the entire 5-step pipeline in sequence
# tmux send-keys -t rmats-pipeline "\
#   cd ~/projects/rmats-differential-splicing && \
#   conda activate rmats-env && \
#   echo '=== Step 0: Download ===' && ./workflow/00_download_data.sh && \
#   echo '=== Step 1: Build STAR Index ===' && ./workflow/01_build_star_index.sh && \
#   echo '=== Step 2: Align ===' && ./workflow/02_align_star.sh && \
#   echo '=== Step 3: Run rMATS ===' && ./workflow/03_run_rmats.sh && \
#   echo '=== PIPELINE COMPLETE ===' \
# " Enter

# We have already downloaded data, so will run a session without data download
# Run the entire 5-step pipeline in sequence
tmux send-keys -t rmats-pipeline "\
  conda activate rmats-env && \
  echo '=== Step 1: Build STAR Index ===' && source ./workflow/01_build_star_index.sh && \
  echo '=== Step 2: Align ===' && source ./workflow/02_align_star.sh && \
  echo '=== Step 3: Run rMATS ===' && source ./workflow/03_run_rmats.sh && \
  echo '=== PIPELINE COMPLETE ===' \
" Enter

# Close your laptop — it will run all night
# Tomorrow morning, check progress:
tmux attach-session -t rmats-pipeline

# Or check without attaching:
# tmux capture-pane -t rmats-pipeline -p | tail -50