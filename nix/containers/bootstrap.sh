REPO_DIR=/home/repo/
MLZ_REPOS="libA libB libC"
for repo in ${MLZ_REPOS}; do
    dest="${REPO_DIR}/${repo}"
    echo "# Setup '${repo}' in ${dest}..."
    git clone -b main --single-branch --depth 1 https://some.repo.address/${repo}.git ${dest}
    cd $dest
    cmake -B ./build -DCMAKE_BUILD_TYPE=Release
    cmake --build ./build -j`nproc`
    cmake --install ./build
    echo "DONE."
done
