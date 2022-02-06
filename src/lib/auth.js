const { getCurrentPlan } = require("./artist");

module.exports = {
  isLoggedIn(req, res, next) {
    if (req.isAuthenticated()) {
      return next();
    }
    return res.redirect("/signin");
  },

  isNotLoggedIn(req, res, next) {
    if (!req.isAuthenticated()) {
      return next();
    }
    return res.redirect("/home");
  },
  async whitPlan(req, res, next) {
    if (await getCurrentPlan(req.user.id_art)) {
      return next();
    }
    return res.render("links/withoutPlan");
  },
};
