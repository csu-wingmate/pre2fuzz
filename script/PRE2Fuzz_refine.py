import argparse

def read_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    return [line.strip() for line in lines]

def write_file(file_path, data):
    with open(file_path, 'w') as file:
        for line in data:
            file.write(line + '\n')

def main(fi, mo, md, o):
    S = read_file(fi)
    
    O = read_file(mo)
    
    L = {}
    for line in read_file(md):
        hex_stream, direction = line.split(',')
        L[hex_stream] = int(direction)
    
    for i in range(len(S)):
        for j in range(i, len(O)):
            if S[i] == O[j]:
                O[i], O[j] = O[j], O[i]
                break
    
    Or = []
    for item in O:
        direction = '00' if L[item] == 0 else '01'
        Or.append(item + ' ' + direction)
    
    write_file(o, Or)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Refine protocol message format inference results.')
    parser.add_argument('-fi', required=True, help='File containing the original order of protocol messages.')
    parser.add_argument('-mo', required=True, help='File containing the format inference results.')
    parser.add_argument('-md', required=True, help='File containing the message direction list.')
    parser.add_argument('-o', required=True, help='Output file to save the refined results.')

    args = parser.parse_args()

    main(args.fi, args.mo, args.md, args.o)
