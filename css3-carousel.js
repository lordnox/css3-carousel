
(function($, window, undefined) {
  var deepCopy = function(source, destination, depth, max) {
    if(depth > max) return destination;
    for(var property in source) {
      if(property in destination) {
        if(typeof(source[property]) === 'object') {
          destination[property] = deepCopy(source[property], destination[property], depth + 1, max);
        }
      } else {
        destination[property] = source[property];
      }
    }
    return destination;
  }

  var css3Carousel = function(selector, options) {
    var element = $(selector);
    if(!element || !element.length) return null;

    options = options || {};
    var defaults = {
        start: 0
      , interval: 5000
      , autoplay: true
      , item: '.css3-carousel-item'
      , base: ''
      , position: {
          prevPrevPrev: 'css3-carousel-visibility-hidden'
        , prevPrev    : 'css3-carousel-visibility-hidden'
        , prev        : 'css3-carousel-visibility-hidden'
        , current     : 'css3-carousel-visibility-visible'
        , next        : 'css3-carousel-visibility-hidden'
        , nextNext    : 'css3-carousel-visibility-hidden'
        , nextNextNext: 'css3-carousel-visibility-hidden'
        , default     : 'css3-carousel-visibility-hidden'
      }
      , direction: {
        forward: 'css3-carousel-direction-forward'
        , reverse: 'css3-carousel-direction-reverse'
      }
      , control: {
          next: '.css3-carousel-control.css3-carousel-control-next'
        , prev: '.css3-carousel-control.css3-carousel-control-prev'
        }
    };

    options = deepCopy(defaults, options || {}, 0, 3);

    if(options.base) {
      element.addClass(options.base);
    }

    var classesToRemove = Object.keys(options.position).map(function (key) {
      return options.position[key];
    }).join(' ');

    var scope = {
      elements: 0
      , position: options.start
    };

    // adds +1 to the position
    var nextPosition = function(position, n) { return (position + (n || 1)) % scope.elements; };
    // adds -1 to the position
    var prevPosition = function(position, n) { return (position - (n || 1) + scope.elements) % scope.elements; };
    // returns the class of the position
    var positionClass = function(position) {
      var pos = scope.position;
      // switch in order to find the most relevant case:
      switch(true) {
        // if position is the current position
        case position === pos: return options.position.current;
        // if position is right before current position:
        case position === prevPosition(pos, 1): return options.position.prev;
        // if position is right after current position:
        case position === nextPosition(pos, 1): return options.position.next;
        // if position is 2 before current position:
        case position === prevPosition(pos, 2): return options.position.prevPrev;
        // if position is 3 before current position:
        case position === prevPosition(pos, 3): return options.position.prevPrevPrev;
        // if position is 2 after current position:
        case position === nextPosition(pos, 2): return options.position.nextNext;
        // if position is 3 after current position:
        case position === nextPosition(pos, 3): return options.position.nextNextNext;
        // if neither:
        default: return options.position.default;
      }
    };

    var updateClasses = function() {
      var items = $(options.item, element);
      scope.elements = items.length;
      items.each(function(position) {
        $(this).removeClass(classesToRemove)
          .addClass(positionClass(position));
      });
    };

    var autoplay = {
      timer: undefined
    };
    var interval = function() {
      api.next();
    };
    var start = function() {
      if(autoplay.timer) return;
      autoplay.timer = setInterval(interval, options.interval);
    };

    var stop = function() {
      if(!autoplay.timer) return;
      autoplay.timer = clearInterval(autoplay.timer);
    };

    var api = {
      prev: function() {
        scope.position = prevPosition(scope.position);
        scope.direction = options.direction.reverse;
        element.removeClass(options.direction.forward)
          .addClass(options.direction.reverse);
        updateClasses();
      },
      next: function() {
        scope.position = nextPosition(scope.position);
        scope.direction = options.direction.forwards;
        element.removeClass(options.direction.reverse)
          .addClass(options.direction.forward);
        updateClasses();
      },
      update: updateClasses,
      start: start,
      stop: stop
    };

    $(options.control.next).click(function(event) {
      event.stopPropagation();
      api.stop();
      api.next();
    });
    $(options.control.prev).click(function(event) {
      event.stopPropagation();
      api.stop();
      api.prev();
    });

    updateClasses();
    if(options.autoplay) {
      start();
    }
    return api;
  };

  $.fn.css3Carousel = function(options) {
    this.each(function(index, selector) {
      var plugin = new css3Carousel(selector, options);
      $(selector).data('css3Carousel', plugin);
    });
    return this;
  }

  $(function() {
    $('.css3-carousel').css3Carousel();
  });
})(jQuery, window);

