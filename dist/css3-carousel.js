(function() {
  (function($, window, undefined_) {
    var css3Carousel, deepCopy;
    deepCopy = function(source, destination, depth, max) {
      var property;
      if (depth > max) {
        return destination;
      }
      for (property in source) {
        if (property in destination) {
          if (typeof source[property] === "object") {
            destination[property] = deepCopy(source[property], destination[property], depth + 1, max);
          }
        } else {
          destination[property] = source[property];
        }
      }
      return destination;
    };
    css3Carousel = function(selector, options) {
      var api, autoplay, classesToRemove, defaults, element, interval, nextPosition, positionClass, prevPosition, scope, start, stop, updateClasses;
      element = $(selector);
      if (!element || !element.length) {
        return;
      }
      options = options || {};
      defaults = {
        start: 0,
        interval: 5000,
        autoplay: true,
        item: ".css3-carousel-item",
        base: "",
        position: {
          prevPrevPrev: "css3-carousel-visibility-hidden",
          prevPrev: "css3-carousel-visibility-hidden",
          prev: "css3-carousel-visibility-hidden",
          current: "css3-carousel-visibility-visible",
          next: "css3-carousel-visibility-hidden",
          nextNext: "css3-carousel-visibility-hidden",
          nextNextNext: "css3-carousel-visibility-hidden",
          "default": "css3-carousel-visibility-hidden"
        },
        direction: {
          forward: "css3-carousel-direction-forward",
          reverse: "css3-carousel-direction-reverse"
        },
        control: {
          next: ".css3-carousel-control.css3-carousel-control-next",
          prev: ".css3-carousel-control.css3-carousel-control-prev"
        }
      };
      options = deepCopy(defaults, options || {}, 0, 3);
      if (options.base) {
        element.addClass(options.base);
      }
      classesToRemove = Object.keys(options.position).map(function(key) {
        return options.position[key];
      }).join(" ");
      scope = {
        elements: 0,
        position: options.start
      };
      nextPosition = function(position, n) {
        return (position + (n || 1)) % scope.elements;
      };
      prevPosition = function(position, n) {
        return (position - (n || 1) + scope.elements) % scope.elements;
      };
      positionClass = function(position) {
        var pos;
        pos = scope.position;
        switch (true) {
          case position === pos:
            return options.position.current;
          case position === prevPosition(pos, 1):
            return options.position.prev;
          case position === nextPosition(pos, 1):
            return options.position.next;
          case position === prevPosition(pos, 2):
            return options.position.prevPrev;
          case position === prevPosition(pos, 3):
            return options.position.prevPrevPrev;
          case position === nextPosition(pos, 2):
            return options.position.nextNext;
          case position === nextPosition(pos, 3):
            return options.position.nextNextNext;
          default:
            return options.position["default"];
        }
      };
      updateClasses = function() {
        var items;
        items = $(options.item, element);
        scope.elements = items.length;
        return items.each(function(position) {
          return $(this).removeClass(classesToRemove).addClass(positionClass(position));
        });
      };
      autoplay = {
        timer: undefined
      };
      interval = function() {
        return api.next();
      };
      start = function() {
        if (autoplay.timer) {
          return;
        }
        return autoplay.timer = setInterval(interval, options.interval);
      };
      stop = function() {
        if (!autoplay.timer) {
          return;
        }
        return autoplay.timer = clearInterval(autoplay.timer);
      };
      api = {
        prev: function() {
          scope.position = prevPosition(scope.position);
          scope.direction = options.direction.reverse;
          element.removeClass(options.direction.forward).addClass(options.direction.reverse);
          return updateClasses();
        },
        next: function() {
          scope.position = nextPosition(scope.position);
          scope.direction = options.direction.forwards;
          element.removeClass(options.direction.reverse).addClass(options.direction.forward);
          return updateClasses();
        },
        update: updateClasses,
        start: start,
        stop: stop
      };
      $(options.control.next).click(function(event) {
        event.stopPropagation();
        api.stop();
        return api.next();
      });
      $(options.control.prev).click(function(event) {
        event.stopPropagation();
        api.stop();
        return api.prev();
      });
      updateClasses();
      if (options.autoplay) {
        start();
      }
      return api;
    };
    $.fn.css3Carousel = function(options) {
      this.each(function(index, selector) {
        var plugin;
        plugin = new css3Carousel(selector, options);
        return $(selector).data("css3Carousel", plugin);
      });
      return this;
    };
    return $(function() {
      return $(".css3-carousel").css3Carousel();
    });
  })(jQuery, window);

}).call(this);

//# sourceMappingURL=css3-carousel.js.map
