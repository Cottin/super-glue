EmployeeDirectory
=================

This serves both as an example for how to use super-glue and at the same time a
project seed to help you bootstrap your next super-glue based project.

TODO
----
- [x] implement 401 throw out
- [x] try getting loadtime down a bit? e.g. react-hot-coffee-boilerplate is really fast. Not as fast but close engough.
- [x] try getting reload time for data_live.coffee down a bit!
- [x] try getting HOT reload times down! e.g. react-hot-boilerplate is really fast!
- [ ] implement simple CrUD to see if the hot loading and everyting holds up
- TESTA
	- dontTransactBefore är skakig. Ex när man har en randomDelay... Finns det ett bättre sätt än dontTransactBefore?
	- [x - this dosn't really matter, just refresh] hot reload när man ändrar data.coffee eller måste man refresha :(
	- hot reload när man ändrar actions.coffee eller måste man refresha :(
	- hot reload när man ändrar app.coffee eller måste man refresha :(
	- hitta bra sätt att bara visa relevanta saker i console.loggen i chrome
- MILESTONE: this would be enough as a seed for small projects
	- Probably do a small project to see if it's nice or not before continuing
	  with the rest of the TODOs.
- [ ] look at general page load time
- [ ] look at if "Manual mode (experimental)" would be interesting to use for react-hot-loader
- radium or similar for styling
- "getter layer"
- try to implement om-approach with requestAnimationFrame and build
- MILESTONE: enough to seed bigger projects
- automated testing
	- replayable actions
	- assertions based on app.data


FAQ
---

If you get error:
It appears that React Hot Loader isn't configured correctly. If you're using NPM, make sure your dependencies don't drag duplicate React distributions into their node_modules and that require("react") corresponds to the React instance you render your app with. If you're using a precompiled version of React, see https://github.com/gaearon/react-hot-loader/tree/master/docs#usage-with-external-react for integration instructions.

...you need to remove react from node_modules in any other module you're requireing.
Ex. I put react as a peer dependency in yun but you still need to remove it from yun/node_modules in order not to get that error message.
