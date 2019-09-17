#!/usr/bin/env python

import sys, json


class DataParser:
    def __init__(self, method, string, *args, **kwargs):
        self.method = method
        self.string = string
        try:
            self.object = json.loads(self.string)
        except ValueError:
            self.object = self.string

    @staticmethod
    def dumps(obj, *args, **kwargs):
        if isinstance(obj, (list, dict)):
            return json.dumps(obj, *args, **kwargs)
        else:
            return obj

    def run(self, *args, **kwargs):
        func = getattr(self, '_' + self.method)
        try:
            return func(*args, **kwargs)
        except Exception as e:
            raise RuntimeError('Failed to run function: %s, %s' % (self.method, e))

    def _get(self, str):
        items = str.split('.')
        item = items.pop(0)
        loop = False

        # [*], [x], [x:y], [x:], [:y]
        if item.startswith('[') and item.endswith(']'):
            index = item.strip("[]")
            # [x]
            if index.isdigit():
                result = self.object[int(index)]
            # [x:y], [x:], [:y]
            elif index.find(":") > -1:
                indices = index.split(':')
                start = indices[0] or 0
                end = indices[1] or len(self.object)
                try:
                    result = getattr(self.object, '__getslice__')(int(start), int(end))
                except Exception as e:
                    raise ValueError('Wrong index format: %s, %s' % (item, e))
            # [*]
            elif index == '*':
                loop = True
                result = self.object
            # Anthing else
            else:
                raise ValueError('Wrong index format: %s, %s' % item)
        # foo()
        elif item.endswith(')'):
            name = item.split('(')[0]
            result = getattr(self.object, name)()
        # foo
        else:
            result = getattr(self.object, 'get')(item)

        if items:
            if loop:
                results = []
                for obj in result:
                    obj = DataParser.dumps(obj)
                    # Call recursively to get result
                    parser = DataParser(self.method, obj)
                    results.append(parser.run('.'.join(items)))
                return results
            else:
                result = DataParser.dumps(result)
                # Call recursively to get result
                parser = DataParser(self.method, result)
                return parser.run('.'.join(items))
        else:
            return result

    def _eval(self, cmd):
        cmd = cmd.replace('{JSON}', 'self.object')
        return eval(cmd)


if __name__ == '__main__':
    parser = DataParser(*sys.argv[1:3])
    result = parser.run(*sys.argv[3:])

    print DataParser.dumps(result)
