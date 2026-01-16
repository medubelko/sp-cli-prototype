# Global variables
product := `sed -n 's/^project = //p' conf.py | sed -e 's/"//g'`  # Read from conf.py
product_short := kebabcase(product)
version := `git describe --tags 2> /dev/null || git rev-parse --short HEAD`
docs_dir := justfile_dir()

# Default values for global options
verbose := "false"
help := "false"

_default: help


# Help command

help command="help":
    #!/usr/bin/bash

    if [ {{command}} == "help" ]; then
    echo "{{product}} {{version}}"
    # TODO: Make this a composed string
    echo """
    Usage:
        just <command> [<option>...]

    These docs are managed with the 'just' task runner. Use it for different
    actions in the docs, including setup, rendering, and checking for problems.

    Run 'just help <command>' to view a command's usage.

    Main commands:
                 build  Render the docs
                 check  Check for problems in the documentation
                 clean  Remove built docs and temporary files
                  help  View help for the commands

    Setup comands:
                 setup  Set up the docs environment
                update  Update the docs base
                remove  Remove the docs environment

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "build" ]; then
    echo """Usage:
        just {{command}} <mode> [<option>...]
    
    Render the docs. Three output types are available:
    
    - 'run' (default) hosts the docs in a local server you can view in the web browser.
      When you save a change to a source file, the server updates the doc in real time.
    - 'html' renders the docs as a static set of HTML pages
    - 'pdf' renders the docs as a PDF file

    Positional arguments:
                  mode  Output type, either 'run' (default), 'html', or 'pdf'

    Options:
               --clean  Clean the built docs and temporary files before
                        building
                --path  Destination path for PDF builds

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "check" ]; then
    echo """Usage:
        just {{command}} <type> [<option>...]
    
    Check for problems in the documentation. Several checks are available:

    - 'style' checks for spelling and style concerns
    - 'markdown' looks for Markdown formatting issues
    - 'links' checks for valid external hyperlinks
    - 'accessibility' checks for web accessibility concerns

    Positional arguments:
                  type  The check to run, either 'all' (default), 'style',
                        'markdown', 'links', or 'accessibility'

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "clean" ]; then
    echo """Usage:
        just {{command}} [<option>...]
    
    Remove all built docs and temporary files. Sometimes, stale files can cause
    build failures, and the only solution is to clear the previous builds.

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "setup" ]; then
    echo """Usage:
        just {{command}} [<option>...]
    
    Set up the docs environment.

    Options:
             --refresh  Completely remove the old environment first

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "remove" ]; then
    echo """Usage:
        just {{command}} [<option>...]
    
    Remove the docs environment.

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi

    if [ {{command}} == "update" ]; then
    echo """Usage:
        just {{command}} [<option>...]
    
    Update the docs base. The foundation of the docs come from Canonical's
    Starter Pack. This command syncs with that project, pulling in new file
    structure, requirements, and templates.

    Global options:
             --verbose  Show more commands in the terminal
                --help  Show this help
    """
    fi


# Docs command
# TODO: Split into component recipes, like check command

build_path := "_build"
default_pdf_path := f'{{docs_dir}}/{{product_short}}-user-guide-{{version}}.pdf'
clean := "false"

[
    arg("pdf_path", long="path"),
    arg("clean", long, value="true"),
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
build mode="run" pdf_path=default_pdf_path clean=clean verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help build
    exit 0
    fi

    just setup

    if [ {{clean}} == "true" ]; then
    just clean
    fi

    if [ {{mode}} == "run" ]; then
    echo "Building docs..."
    sleep 1

    if [ {{verbose}} == "false" ]; then
    echo "Docs hosted at http://127.0.0.0:8000"
    else
    echo """
    . .sphinx/venv/bin/activate; .sphinx/venv/bin/sphinx-build --fail-on-warning --keep-going -b dirhtml "." "_build" -w .sphinx/warnings.txt -c . -d .sphinx/.doctrees -j auto
    Running Sphinx v7.4.7
    loading translations [en]... done
    ...
    reading sources... [100%] how-to/migrate-from-pre-extension
    writing additional pages... search done
    dumping search index in English (code: en)... done
    dumping object inventory... done
    sphinx-sitemap: sitemap.xml was generated for URL / in /home/med/dev/sphinx-docs-starter-pack/docs/_build/sitemap.xml
    build succeeded.

    The HTML pages are in {{build_path}}.
    [sphinx-autobuild] Serving on http://127.0.0.1:8000
    [sphinx-autobuild] Waiting to detect changes..."""
    fi
    fi

    if [ {{mode}} == "html" ]; then
    echo "Building docs..."
    sleep 1
    if [ {{verbose}} == "false" ]; then
    echo "Docs rendered to {{build_path}}"
    else
    echo """
    . .sphinx/venv/bin/activate; .sphinx/venv/bin/sphinx-build --fail-on-warning --keep-going -b dirhtml "." "_build" -w .sphinx/warnings.txt -c . -d .sphinx/.doctrees -j auto
    Running Sphinx v7.4.7
    loading translations [en]... done
    ...
    reading sources... [100%] how-to/migrate-from-pre-extension
    writing additional pages... search done
    dumping search index in English (code: en)... done
    dumping object inventory... done
    sphinx-sitemap: sitemap.xml was generated for URL / in /home/med/dev/sphinx-docs-starter-pack/docs/_build/sitemap.xml
    build succeeded.

    The HTML pages are in {{build_path}}."""
    fi
    fi

    if [ {{mode}} == "pdf" ]; then
    echo "Building PDF..."
    sleep 1
    echo "Docs saved as {{pdf_path}}"
    fi

[private]
auto *args:
    @just build {{args}}

[private]
run *args:
    @just build {{args}}

[private]
serve *args:
    @just build {{args}}

[private]
server *args:
    @just build {{args}}

[private]
html *args:
    @just build html {{args}}

[private]
pdf *args:
    @just build pdf {{args}}


# Check command

[
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
check mode="all" verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help check
    exit 0
    fi

    if [ {{verbose}} == "true" ]; then
    verbose=--verbose # TODO: Read from {{verbose}} instead
    fi

    just build html $verbose
    echo "Checking for problems..."
    sleep 1

    if [ {{mode}} == "style" ] || [ {{mode}} == "all" ]; then
    just style $verbose
    fi

    if [ {{mode}} == "markdown" ] || [ {{mode}} == "all" ]; then
    just markdown $verbose
    fi

    if [ {{mode}} == "links" ] || [ {{mode}} == "all" ]; then
    just links $verbose
    fi

    if [ {{mode}} == "accessibility" ] || [ {{mode}} == "all" ]; then
    just accessibility $verbose
    fi

    echo "Checks complete"

[private]
[arg("verbose", long, value="true")]
style verbose=verbose:
    #!/usr/bin/bash

    echo "Checking style..."
    sleep 2

    if [ {{verbose}} == "true" ]; then
    echo """✔ 0 errors, 0 warnings and 0 suggestions in stdin."""
    fi

[private]
[arg("verbose", long, value="true")]
markdown verbose=verbose:
    #!/usr/bin/bash

    echo "Linting Markdown files..."
    sleep 1

    #if [ {{verbose}} == "true" ]; then
    # Print errors
    #fi

[private]
[arg("verbose", long, value="true")]
links verbose=verbose:
    #!/usr/bin/bash

    echo "Checking links..."
    sleep 5

    if [ {{verbose}} == "true" ]; then
    echo """...
    (reference/automatic_checks_accessibility: line   41) ok        https://github.com/pa11y/pa11y#command-line-configuration
    (how-to/set-up-sitemaps: line  164) ok        https://github.com/canonical/ubuntu-documentation-library/blob/main/scripts/generate_sitemap.py
    (reference/automatic_checks: line   39) ok        https://github.com/canonical/documentation-workflows/
    (how-to/customise-pdf: line  118) ok        https://github.com/canonical/canonical-sphinx/blob/main/canonical_sphinx/theme/PDF/latex_elements_template.txt"""
    fi

[private]
[arg("verbose", long, value="true")]
accessibility verbose=verbose:
    #!/usr/bin/bash

    echo "Checking accessibility..."
    sleep 2

    #if [ {{verbose}} == "true" ]; then
    # Print errors
    #fi

[private]
lint *args:
    just check *args


# Clean command

[
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
clean verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help clean
    exit 0
    fi

    # Remove .sphinx, _build, and so on
    echo "Removed built docs and temporary files"


# Setup command

refresh := "false"

[
    arg("refresh", long,  value="true"),
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
setup refresh=refresh verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help setup
    exit 0
    fi

    if [ {{refresh}} == "true" ]; then
    just remove
    fi

    if [ ! -e ".venv" ]; then
    echo "Setting up docs environment..."
    sleep 2
    if [ {{verbose}} == "true" ]; then
    echo """pip install  --require-virtualenv --upgrade -r requirements.txt --log .sphinx/venv/pip_install.log"""
    fi
    touch .venv
    echo "Docs environment ready."
    else
    echo "Found docs environment."
    fi

[private]
install *args:
    just setup *args


# Remove command

[
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
remove verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help remove
    exit 0
    fi

    if [ -e ".venv" ]; then
    sleep 2
    rm .venv
    echo "Removed docs environment."
    else
    echo "No docs environment to remove."
    fi


# Update command

[
    arg("verbose", long, value="true"),
    arg("help", long, value="true")
]
update verbose=verbose help=help:
    #!/usr/bin/bash

    if [ {{help}} == "true" ]; then
    just help update
    exit 0
    fi

    echo "Updating docs base..."
    sleep 1
    
    if [ {{verbose}} == "true" ]; then
    echo "Checking local version"
    echo "Local version and release version are the same"
    fi

    echo "This version is up to date"
