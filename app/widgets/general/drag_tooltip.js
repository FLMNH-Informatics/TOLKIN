//= require <widgets/templates/tooltip>

JooseModule('General', function () {
  JooseClass('DragTooltip', {
    isa: Templates.Tooltip,
    has: {
      dragHandler:  { },
      element:      { },
      over:         { is: 'ro', init: null },
      extraClasses: { is: 'ro', init: 'drag-tooltip' },
      klass:        { is: 'ro', required: true, nullable: false },
      conditions:   { is: 'ro', required: true, nullable: false }
    },
    after: {
      initialize: function () {
        var me = this;
        this._element = $(this.id());
        this._dragHandler = function (event) {
          me.move(event.pointer());
          Droppables.show([Event.pointerX(event), Event.pointerY(event)], this._element);
        }
        document.observe('mousemove', this._dragHandler);
      }
    },
    methods: {
      move: function(pointer) {
        $(this.id()).style.left = (pointer.x - 15) + 'px';
        $(this.id()).style.top = (pointer.y - 15) + 'px';
      },
      onDragend: function () {
        if(Droppables.last_active) {
          Droppables.last_active.onDrop(this.klass(), this.conditions());
        }
        this.destroy();
      },
      destroy: function () {
        document.stopObserving('mousemove', this._dragHandler);
        $(this.id()).remove();
        this.parent().widgets().remove(this);
      }
//      onDrag: function (event) {
//        this.move(event.pointer());
//      }
    }
  });
});