Rebol [
    Title: {Trello Interaction Test}
]

; This is the public API key for my hostilefork account.  This has to be public
; in order to identify the app to a user.  For a real app, they suggest making
; an account distinct from the developer's personal account--but this is just
; a test, so who cares.
;
api-key: "73d38a2fbb0bbcffbd8d184b5351b902"

; The Trello "client.js" API does the legwork for asking you to log in and
; get privileges to read/write a board.
;
; https://developers.trello.com/docs/api-introduction#section-intro-to-clientjs
;
js-do https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js
js-do join https://trello.com/1/client.js?key= api-key

; Trello capabilities for embedding interactive single cards on a site
; https://developers.trello.com/docs/cards
;
js-do https://p.trellocdn.com/embed.min.js


; Do a test to see if we can authenticate a Trello user via client.js
;
authenticate-trello: js-awaiter [] {
    return new Promise((resolve, reject) => {
        let authenticationSuccess = function() {
            console.log("authenticate success")
            resolve(reb.Logic(true))
        }

        let authenticationFailure = function() {
            console.log("authenticate fail")
            resolve(reb.Logic(false))
        }

        console.log("authenticate try")
        window.Trello.authorize({
          type: 'popup',
          name: 'Getting Started Application',
          scope: {
            read: 'true',
            write: 'false' },
          expiration: 'never',
          success: authenticationSuccess,
          error: authenticationFailure
        })
    })
}

if not authenticate-trello [
    fail "Authentication did not succeed"
]

print "Authentication successful"

; Test to see if we can embed a card in the REPL

replpad-write/html {<div id="trello-card"></div>}

js-do/local {
    let el = document.getElementById("trello-card")
    window.TrelloCards.create('https://trello.com/c/VroL3d4h/', el, {
      compact: false,
      onLoad: function(evt) {
        //
        // Callback after the card has loaded
        // Can be used to resize the parent container
        // Trello example used evt.path[0] but that is non-standard
        // https://stackoverflow.com/a/39245638
        //
        var iframe = evt.composedPath()[0];
        let el = document.getElementById("trello-card")
        el.style.height = iframe.clientHeight;
        el.style.width = iframe.clientWidth;
      },
      onResize: function(dim) {
        // Callback after the card resizes when the comments
        // section is expanded or collapsed
        //
        let el = document.getElementById("trello-card")
        el.style.height = dim.height;
      }
    })
}
