
import sys
import argparse
import re

class colours:
    HEADER = '\033[95m'
    OKAY = '\033[92m'
    WARN = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

characters = []
error = False

def print_chars(args):

    if args.filename:
        if args.f:
            file = open(args.filename, "w")
        else:
            try:
                file = open(args.filename, "x")
            except:
                print(colours.FAIL + "ERROR: Failed to write to file. Does it already exist?" + colours.ENDC)
                exit(1)

        for i in characters:
            file.write("\\x" + i)
        file.write("\n")
        file.close()
        print(colours.OKAY + "Done!" + colours.ENDC)
        return

    for i in characters:
        print("\\x" + i, end='')
    print(colours.OKAY + "\nDone!" + colours.ENDC)


parser = argparse.ArgumentParser(description="Generate hex from \\x00 - \\xff")
group = parser.add_mutually_exclusive_group()
group.add_argument("-a", help="Print all hex values from \\x00 to \\xff", action="store_true")
group.add_argument("-b", help="Bad characters to exclude in format '\\x00\\x01\\x02'", dest='bad_characters')
parser.add_argument("-w", help="Write to file.", dest="filename")
parser.add_argument("-f", help="Force write to file.", action="store_true")
args = parser.parse_args()

if len(sys.argv) == 1:
    parser.print_help()

if (args.f or args.filename) and not (args.a or args.bad_characters):
    print(colours.FAIL + "ERROR: -w or -f require either -a or -b..." + colours.ENDC)
    exit(1)

elif args.f and not args.filename:
    print(colours.WARN + "WARNING: Ignoring -f since -w not used..." + colours.ENDC)

if args.a:
    print(colours.HEADER + "Printing all characters..." + colours.ENDC)

    for i in range(0, 256):
        characters.append("{:02x}".format(i))

    print_chars(args)

elif args.bad_characters:
    for index in range(0, len(args.bad_characters), 4):
        if not re.search(r"\\x[0-9a-f]{2}", args.bad_characters[index:index + 4]):
            print(colours.WARN + "WARNING: " + args.bad_characters[index:index + 4] + " is the incorrect format..." + colours.ENDC) 
            error = True

    if not ((len(args.bad_characters) % 4) == 0) or (len(args.bad_characters) < 4):
        error = True

    if error:
        print(colours.FAIL + "ERROR: Bad characters are incorrect format. Exitting..." + colours.ENDC)
        exit(1)

    print(colours.HEADER + "Excluding bad characters: " + args.bad_characters + "..." + colours.ENDC)

    for x in range(0, 256):
        if ("\\x" + "{:02x}".format(x)) in args.bad_characters:
            continue

        characters.append("{:02x}".format(x))
    print_chars(args)

