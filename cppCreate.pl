#!/usr/bin/perl
use strict;
use warnings;
use File::Path qw(make_path);

print "Enter the project name: ";
my $project_name = <STDIN>;
chomp($project_name);

# Create project directory
make_path($project_name);

# Create src directory
make_path("$project_name/src");

# Generate main.cpp
open my $main_cpp, '>', "$project_name/src/main.cpp" or die $!;
print $main_cpp <<'END_MAIN_CPP';
#include <iostream>
#include <Eigen/Dense>
#include <dlib/matrix.h>

int main() {
    // Eigen example
    # Eigen::MatrixXd mat(2, 2);
    # mat(0, 0) = 3;
    # mat(1, 0) = 2.5;
    # mat(0, 1) = -1;
    # mat(1, 1) = mat(1, 0) + mat(0, 1);
    #
    # std::cout << "Eigen Matrix:\n" << mat << std::endl;
    #
    # // dlib example
    # dlib::matrix<double> dlib_mat(2, 2);
    # dlib_mat = 3, -1,
    #            2.5, 1.5;
    #
    # std::cout << "dlib Matrix:\n" << dlib_mat << std::endl;

    std::cout << "Hello, World!" << std::endl;

    return 0;
}
END_MAIN_CPP
close $main_cpp;

# Generate CMakeLists.txt
open my $cmake_lists, '>', "$project_name/CMakeLists.txt" or die $!;
print $cmake_lists <<"END_CMAKE";
cmake_minimum_required(VERSION 3.10)
project($project_name)

set(CMAKE_CXX_STANDARD 17)

# Find Eigen3 package
find_package(Eigen3 3.3 REQUIRED NO_MODULE)

# Find dlib package
find_package(dlib REQUIRED)

# Add the executable
add_executable($project_name src/main.cpp)

# Link Eigen and dlib libraries
target_link_libraries($project_name Eigen3::Eigen dlib::dlib)
END_CMAKE
close $cmake_lists;

# Generate default.nix
open my $default_nix, '>', "$project_name/default.nix" or die $!;
print $default_nix <<"END_NIX";
with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "$project_name";
  version = "1.0.0";

  buildInputs = [
    cmake
    eigen
    dlib
  ];

  src = ./.;

  # Build phase
  buildPhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make
  '';

  # Install phase (optional for this example)
  installPhase = ''
    mkdir -p \$out/bin
    cp build/$project_name \$out/bin/
  '';
}
END_NIX
close $default_nix;

# Generate build script
open my $build_script, '>', "$project_name/build.sh" or die $!;
print $build_script <<'END_BUILD_SCRIPT';
#!/bin/bash
nix-shell --run "mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make"
END_BUILD_SCRIPT
close $build_script 
chmod 0755, "$project_name/build.sh";

# Generate run script
open my $run_script, '>', "$project_name/run.sh" or die $!;
print $run_script <<"END_RUN_SCRIPT";
#!/bin/bash
./build/$project_name
END_RUN_SCRIPT
close $run_script;
chmod 0755, "$project_name/run.sh";

print "Project $project_name created successfully!\n";

