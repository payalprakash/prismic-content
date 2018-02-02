const Prismic = require('prismic-javascript');
const PrismicDOM = require('prismic-dom');
const request = require('request');
const Cookies = require('cookies');
const PrismicConfig = require('./prismic-configuration');
const Onboarding = require('./onboarding');
const app = require('./config');

const PORT = app.get('port');

app.listen(PORT, () => {
  Onboarding.trigger();
  process.stdout.write(`Point your browser to: http://localhost:${PORT}\n`);
});

// Middleware to inject prismic context
app.use((req, res, next) => {
  res.locals.ctx = {
    endpoint: PrismicConfig.apiEndpoint,
    linkResolver: PrismicConfig.linkResolver,
  };
  // add PrismicDOM in locals to access them in templates.
  res.locals.PrismicDOM = PrismicDOM;
  Prismic.api(PrismicConfig.apiEndpoint, {
    accessToken: PrismicConfig.accessToken,
    req,
  }).then((api) => {
    req.prismic = { api };
    next();
  }).catch((error) => {
    next(error.message);
  });
});

/*
 *  --[ INSERT YOUR ROUTES HERE ]--
 */

/*
 * Route with documentation to build your project with prismic
 */
app.get('/', (req, res) => {
  const homePageId = 'documentation-home';
  req.prismic.api.getSingle(homePageId).then(function(document) {
    if (document) {
      // pageContent is a document, or null if there is no match
      res.render('home', {
       document
      });
    } else {
      res.status(404).send('404 not found');
    }
  });
});

// Route to get an article.
app.get('/articles/:uid', (req, res, next) => {
  // We store the param uid in a variable
  const uid = req.params.uid;
  // We are using the function to get a document by its uid
  req.prismic.api.getByUID('articles', uid)
    .then((articleContent) => {
      //console.log(articleContent);
      if (articleContent) {
        // pageContent is a document, or null if there is no match
        res.render('article', {
          // Where 'page' is the name of your pug template file (page.pug)
          articleContent,
        });
      } else {
        res.status(404).send('404 not found');
      }
    })
    .catch((error) => {
      next(`error when retriving page ${error.message}`);
    });
});

// Route to get an article.
app.get('/user_guide/:uid', (req, res, next) => {
  // We store the param uid in a variable
  const uid = req.params.uid;
  // We are using the function to get a document by its uid
  req.prismic.api.getByUID('user_guide', uid)
    .then((guideContent) => {
      //console.log(guideContent);
      if (guideContent) {
        // pageContent is a document, or null if there is no match
        res.render('guide', {
          // Where 'page' is the name of your pug template file (page.pug)
          guideContent,
        });
      } else {
        res.status(404).send('404 not found');
      }
    })
    .catch((error) => {
      next(`error when retriving page ${error.message}`);
    });
});

// Route to get an article.
app.get('/faqs/:uid', (req, res, next) => {
  // We store the param uid in a variable
  const uid = req.params.uid;
  // We are using the function to get a document by its uid
  req.prismic.api.getByUID('faqs', uid)
    .then((faqContent) => {
      //console.log(faqContent);
      if (faqContent) {
        // pageContent is a document, or null if there is no match
        res.render('faq', {
          // Where 'page' is the name of your pug template file (page.pug)
          faqContent,
        });
      } else {
        res.status(404).send('404 not found');
      }
    })
    .catch((error) => {
      next(`error when retriving page ${error.message}`);
    });
});

/*
 * Prismic documentation to build your project with prismic
 */
app.get('/help', (req, res) => {
  const repoRegexp = /^(https?:\/\/([-\w]+)\.[a-z]+\.(io|dev))\/api(\/v2)?$/;
  const [_, repoURL, name, extension, apiVersion] = PrismicConfig.apiEndpoint.match(repoRegexp);
  const { host } = req.headers;
  const isConfigured = name !== 'your-repo-name';
  res.render('help', {
    isConfigured,
    repoURL,
    name,
    host,
  });
});

/*
 * Preconfigured prismic preview
 */
app.get('/preview', (req, res) => {
  const { token } = req.query;
  if (token) {
    req.prismic.api.previewSession(token, PrismicConfig.linkResolver, '/').then((url) => {
      const cookies = new Cookies(req, res);
      cookies.set(Prismic.previewCookie, token, { maxAge: 30 * 60 * 1000, path: '/', httpOnly: false });
      res.redirect(302, url);
    }).catch((err) => {
      res.status(500).send(`Error 500 in preview: ${err.message}`);
    });
  } else {
    res.send(400, 'Missing token from querystring');
  }
});

