module.exports = {

    isLoggedIn(req, res, next) {
        if (req.isAuthenticated()) {
            return next();
        }
        return res.redirect('/signinArtist');
    },

    isNotLoggedIn(req, res, next) {

    }
}