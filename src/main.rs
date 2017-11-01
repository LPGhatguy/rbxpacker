#[macro_use]
extern crate serde_derive;

#[macro_use]
extern crate clap;

extern crate globset;
extern crate serde;
extern crate serde_json;

use std::path::{Component, Path, PathBuf};
use std::fs::{self, File};
use std::io::Read;
use std::process;

use globset::{Glob, GlobSetBuilder};

static TEMPLATE: &'static str = include_str!("import-template.lua");

#[derive(Serialize, Deserialize, Debug)]
struct FileEntry {
    path: Vec<String>,
    contents: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct FileEntrySet {
    files: Vec<FileEntry>,
}

fn get_files(root: &Path) -> Vec<PathBuf> {
    let mut buffer = Vec::new();

    get_files_inner(root, &mut buffer);

    buffer
}

fn get_files_inner(root: &Path, buffer: &mut Vec<PathBuf>) {
    let children = match fs::read_dir(root) {
        Ok(v) => v,
        Err(_) => {
            eprintln!("Unable to read from directory {}", root.display());
            process::exit(1);
        }
    };

    for child in children {
        let path = child.unwrap().path();

        if path.is_file() {
            buffer.push(path);
        } else if path.is_dir() {
            get_files_inner(&path, buffer);
        }
    }
}

fn read_file(path: &Path) -> String {
    let mut f = match File::open(path) {
        Ok(v) => v,
        Err(err) => {
            eprintln!("Unable to open file {}: {}", path.display(), err);
            process::exit(1);
        }
    };

    let mut contents = String::new();

    match f.read_to_string(&mut contents) {
        Ok(_) => {}
        Err(err) => {
            eprintln!("Couldn't read from file {}: {}", path.display(), err);
            process::exit(1);
        }
    }

    contents
}

fn path_to_rbx(path: &Path) -> Vec<String> {
    let mut result = Vec::new();

    for component in path.components() {
        match component {
            Component::Normal(piece) => {
                result.push(piece.to_str().unwrap().to_string());
            }
            _ => {}
        }
    }

    result
}

fn main() {
    let matches = clap_app!(rbxpacker =>
        (version: env!("CARGO_PKG_VERSION"))
        (author: env!("CARGO_PKG_AUTHORS"))
        (about: env!("CARGO_PKG_DESCRIPTION"))
        (@arg INPUT: +required "Path to the code to bundle into an install script")
        (@arg name: --name +takes_value "The name of the package to show in the installer")
        (@arg folder: --folder +takes_value "Wraps the package in a Folder with the given name")
        (@arg exclude: --exclude +takes_value +multiple "Exclude the given glob patterns from the bundle")
        (@arg no_collapse: --no_collapse "Turns off collapsing of init.lua values into ModuleScript containers")
    ).get_matches();

    let input = matches.value_of("INPUT").unwrap();
    let package_name = matches.value_of("name").unwrap_or("<UNKNOWN>");
    let folder = matches.value_of("folder");
    let collapse = match matches.occurrences_of("no_collapse") {
        0 => true,
        _ => false,
    };

    let exclude_glob = match matches.values_of("exclude") {
        Some(excludes_iter) => {
            let mut builder = GlobSetBuilder::new();

            for pattern in excludes_iter {
                builder.add(Glob::new(pattern).unwrap());
            }

            Some(builder.build().unwrap())
        }
        None => None,
    };

    let root = Path::new(input);

    let files = get_files(&root)
        .iter()
        .filter(|path| {
            if let Some(ref matcher) = exclude_glob {
                !matcher.is_match(path)
            } else {
                true
            }
        })
        .map(|path| {
            let mut rbx_path = path_to_rbx(path.strip_prefix(root).unwrap());

            if let Some(value) = folder {
                rbx_path.insert(0, value.to_string());
            }

            FileEntry {
                path: rbx_path,
                contents: read_file(path),
            }
        })
        .collect::<Vec<_>>();

    let result = FileEntrySet { files };

    let encoded = serde_json::to_string(&result).unwrap();

    let result = TEMPLATE
        .replace("{{NAME}}", package_name)
        .replace("{{COLLAPSE}}", if collapse { "true" } else { "false" })
        .replace("{{VERSION}}", env!("CARGO_PKG_VERSION"))
        .replace("{{SOURCE}}", &encoded);

    println!("{}", result);
}
