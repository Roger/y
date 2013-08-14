#!/usr/bin/env python
from __future__ import print_function
import os
import imp
import sys

import edn_format

from yel_status import NOT_FOUND
from yel_utils import pythonify, Options

path = [os.path.join(os.path.dirname(__file__), 'commands')]

def import_command(name):
    file_, pathname, description = imp.find_module(name, path)
    module = imp.load_module(name, file_, pathname, description)
    file_.close()
    return module

def main(name, args):

    if len(args) == 0:
        options_str = "{}"
    elif args[0][0] in ("[", "(") and args[-1][-1] in ("]", ")"):
        options_str = " ".join(args)
    elif args[0][0:2] == "#{" and args[-1][-1] == "}":
        options_str = " ".join(args)
    elif len(args) == 1:
        options_str = args[0]
    else:
        options_str = "{%s}" % " ".join(args)

    parsed_options = pythonify(edn_format.loads(options_str))
    if isinstance(parsed_options, dict):
        dict_options = parsed_options 
    else:
        dict_options = dict(value=parsed_options)

    options = Options(dict_options)
    try:
        command = import_command(name)
        stdin = sys.stdin
        stdout = sys.stdout
        status = command.run(options, stdin, stdout)
        stdout.flush()
        sys.exit(status)
    except ImportError:
        error("Command {} not found".format(name), NOT_FOUND)

if __name__ == "__main__":
    name = sys.argv[1]
    args = sys.argv[2:]
    main(name, args)