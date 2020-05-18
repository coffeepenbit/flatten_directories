function teardown {
    rm -rf target_dir
}


@test "No input" {
    run ./flatten_directories.sh -vd

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 1 ]
}


@test "Non-existant directory" {
    run ./flatten_directories.sh -vd nonexistant_directory

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 1 ]
}


@test "Empty directory" {
    mkdir target_dir

    run ./flatten_directories.sh -vd target_dir

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
}


@test "Single file directory" {
    mkdir target_dir
    touch target_dir/book.epub

    run ./flatten_directories.sh -vd target_dir

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ -d target_dir ]
    [ -f target_dir/book.epub ]
    [ "$status" -eq 0 ]
}


@test "One subdir, one level" {
    mkdir target_dir
    mkdir target_dir/subdir
    touch target_dir/subdir/book.epub

    run ./flatten_directories.sh -vd target_dir

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d target_dir ]
    [ ! -d target_dir/subdir ]
    [ -f target_dir/subdir_book.epub ]
}


@test "One subdir, two levels" {
    mkdir target_dir
    mkdir target_dir/subdir1
    touch target_dir/subdir1/book.epub
    mkdir target_dir/subdir1/subdir2
    touch target_dir/subdir1/subdir2/book2.epub

    run ./flatten_directories.sh -vd target_dir

    tree > test_debug.txt


    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d target_dir ]
    [ ! -d target_dir/subdir1 ]
    [ -f target_dir/subdir1_book.epub ]
    [ -f target_dir/subdir1_subdir2_book2.epub ]
}


@test "Two subdirs, one level" {
    mkdir target_dir
    mkdir target_dir/subdir1
    touch target_dir/subdir1/book.epub
    mkdir target_dir/subdir2
    touch target_dir/subdir2/book2.epub

    run ./flatten_directories.sh -vd target_dir

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d target_dir ]
    [ ! -d target_dir/subdir1 ]
    [ ! -d target_dir/subdir2 ]
    [ -f target_dir/subdir1_book.epub ]
    [ -f target_dir/subdir2_book2.epub ]
}


@test "Two subdirs, duplicate file name" {
    mkdir target_dir
    mkdir target_dir/subdir1
    touch target_dir/subdir1/book.epub
    mkdir target_dir/subdir2
    touch target_dir/subdir2/book.epub

    run ./flatten_directories.sh -vd target_dir

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d target_dir ]
    [ ! -d target_dir/subdir1 ]
    [ ! -d target_dir/subdir2 ]
    [ -f target_dir/subdir1_book.epub ]
    [ -f target_dir/subdir2_book.epub ]
}


@test "Regex" {
    mkdir target_dir
    mkdir target_dir/subdir1
    touch target_dir/subdir1/book.epub
    touch target_dir/subdir1/book.mobi
    touch target_dir/subdir1/cover.jpg
    mkdir target_dir/subdir2
    touch target_dir/subdir2/book2.epub
    touch target_dir/subdir2/book2.mobi
    touch target_dir/subdir2/cover.jpg

    run ./flatten_directories.sh -vd -e '.*\.\(epub\|mobsi\)$' -- target_dir 

    echo -e "status:\n${status}\n"
    echo -e "output:\n${output}\n"
    [ "$status" -eq 0 ]
    [ -d target_dir ]
    [ -d target_dir/subdir1 ] # Exists because not empty directory
    [ -d target_dir/subdir2 ] # Exists because not empty directory
    [ -f target_dir/subdir1_book.epub ]
    [ -f target_dir/subdir1_book.mobi ]
    [ -f target_dir/subdir2_book2.epub ]
    [ -f target_dir/subdir2_book2.mobi ]
    [ ! -f target_dir/subdir1_cover.jpg ]
    [ ! -f target_dir/subdir2_cover.jpg ]
}