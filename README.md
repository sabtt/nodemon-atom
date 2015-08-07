Nodemon Atom
---

Nodemon Atom is a package to run nodemon from within atom.

To start nodemon-atom use `Ctrl-Shift-E`.

First select `Set Args` and erase everything in the window that pops up.
Then put in your arguments to nodemon just as you would the command line.

If I wanted to run the script in my project root call myscript.js
NODEMON_ARGUMENTS would look like this

```bash
myscript.js
```

If I wanted to run a script in a subdirectory (heres an express.js example)

```bash
bin/www
```

What if I want to run a python file as a module???

Funny you should ask, heres an example of running a tornado web application.

```bash
-e py,js,html --exec "python -m web.app"
```
> -e tells nodemon to reload on changes to files that have those extensions.
> So I also reload on html and js changes because tornado has kept those files
> in memory for me in the past and I've had to reload to get them to display
> the latest changes

But I'm a c++ developer!

Good for you!

```bash
-e h,cpp --exec "make && ./myapp"
```

![nodemon-atom](https://f.cloud.nodemonhub.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
