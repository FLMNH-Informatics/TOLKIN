//= require <templates/window>
//= require "image_gallery"
//= require <morphology/matrices/cell>

JooseModule('Morphology.Matrices.Cells', function () {
  JooseClass('Window', {
    isa: Templates.Window,
    has: {
      contents: { is: 'ro' },
      context: { is: 'ro', required: true, nullable: false },
      title: { is: 'ro', init: 'Cell Details' },
      cell: { is: 'ro', lazy: true, init: function () {
          if(this._cellId) {
            return Morphology.Matrices.Cell.find(this._cellId, this.context())
          } else {
            return new Morphology.Matrices.Cell({ context: this.context(), attributes: { character_id: this._xItemId, otu_id: this._yItemId }})
          }
        } },
      cellId: { required: true },
      xItemId: { required: true, nullable: false }, // eventually replace element as being required for cell, only have listeners
      yItemId: { required: true, nullable: false },
      datagrid: { is: 'ro', required: true, nullable: false },
      width: { is: 'ro', init: 500 },
      height: { is: 'ro', init: 360 },
      widgets: { is: 'ro', init: function () { return $Reg({
          imageGallery: new Morphology.Matrices.Cells.ImageGallery({ parent: this, cell: this.cell() })
      }, this ) } }
    },
    after: {
      initialize: function () {
        this.cell();
        params['cell_id'] = this.cell().id();
      },
      close: function () {
        this.destroy();
      },
      unload: function () {
        this.datagrid().cellFocus().selectedCell().revert();
        this.datagrid().cellFocus().unselectElement();
      },
      _displayRender: function () {
        this._loadPostObservers();
      }
    },
    override: {
      render: function() {
        this._loadPreObservers();
        this.SUPER({ yield: this.contents() });//+this.widgets().get('imageGallery').renderToString() });
        return this;
      }
    },
    methods: {
      loadContents: function(options) {
        var window = this;
        var path = this.cell().id() ? '/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/state_codings/' + this.cell().id() : '/projects/' + params['project_id'] + '/matrices/' + params['matrix_id'] + '/state_codings/new';
        var parameters = this.cell().id() ? { } : { character_id: this.cell().attributes().character_id, otu_id: this.cell().attributes().otu_id };
        new Ajax.Request(path, {
          method: 'get',
          parameters: parameters,
          onSuccess: function(transport) {
            window._contents = transport.responseText;
            if(options.onSuccess) {
              options.onSuccess();
            }
          }
        })
      },

      onSubmit: function(event) {
        var window = this;
        event.stop();
        this.context().notifier().working('Saving ...');
        event.element().request({
          onSuccess: function(transport) {
            var result = transport.responseText.evalJSON();
            window.datagrid().cellFocus().selectedCell().element().writeAttribute('data-cell-id', result.new_cell_id);
            window.datagrid().cellFocus().selectedCell().updateInitialValues();
            $('changes_list').replace(result.changes_list);
            $('commit_changes_button').enable();
            window.context().notifier().success('Cell successfully saved.');
          }
        });
      },

      onChange: Event.delegate({
        '.coding_state_checkbox': function(event) {
          var state = event.element().id.match(/^state_(\w+)$/)[1];
          switch(state) {
            case 'dash':
              state = '-'; break;
            case 'question_mark':
              state = '?'; break;
          }
          this.datagrid().cellFocus().selectedCell().toggleState(state);
          $('coding_status').setValue('complete');
          this.datagrid().cellFocus().selectedCell().setStatus('complete');
        },
        '#coding_status': function(event) {
          this.datagrid().cellFocus().selectedCell().setStatus($F(event.element()));
        }
      }),

      _loadPreObservers: function() {
        var window = this;
        function clearCodings() {
          $$('.coding_state_checkbox').each(function(checkbox) {
            checkbox.setValue(null);
          });
        }

        function clearSpecialCodings() {
          $('state_dash').setValue(null);
          $('state_question_mark').setValue(null);
        }

        document.stopObserving('keyup');
    Event.observe(document, 'keyup', function(e) {
          if($('cell_details')) {
            var code = e.keycode ? e.keycode : e.which;
            var element, state;
            if(code == 48) {
              clearSpecialCodings();
              element = $('state_0')
              state = '0';
            } else if(code == 49) {
              clearSpecialCodings();
              element = $('state_1')
              state = '1';
            } else if(code == 50) {
              clearSpecialCodings();
              element = $('state_2')
              state = '2';
            } else if(code == 51) {
              clearSpecialCodings();
              element = $('state_3')
              state = '3';
            } else if(code == 52) {
              clearSpecialCodings();
              element = $('state_4')
              state = '4';
            } else if(code == 53) {
              clearSpecialCodings();
              element = $('state_5')
              state = '5';
            } else if(code == 54) {
              clearSpecialCodings();
              element = $('state_6')
              state = '6';
            } else if(code == 55) {
              clearSpecialCodings();
              element = $('state_7')
              state = '7';
            } else if(code == 56) {
              clearSpecialCodings();
              element = $('state_8')
              state = '8';
            } else if(code == 57) {
              clearSpecialCodings();
              element = $('state_9')
              state = '9';
            } else if(code == 63) {
              clearCodings();
              element = $('state_question_mark');
              state = '?';
            } else if(code == 45) {
              clearCodings();
              element = $('state_dash');
              state = '-';
            } else if(code == 67 || code == 99) {
              window.datagrid().cellFocus().selectedCell().setStatus('complete');
              $('coding_status').selectedIndex=2;
            } else if (code == 73 || code == 105) {
              window.datagrid().cellFocus().selectedCell().setStatus('incomplete');
              $('coding_status').selectedIndex=1;
            } else if (code == 80 || code == 112) {
              window.datagrid().cellFocus().selectedCell().setStatus('problem');
              $('coding_status').selectedIndex=3;
            }

            if(element) {
              window.datagrid().cellFocus().selectedCell().toggleState(state);
              if (element.checked) {
                element.checked=false;
              } else {
                element.checked=true;
              }
              window.datagrid().cellFocus().selectedCell().setStatus('complete');
              $('coding_status').selectedIndex=2;
              element.focus();
            }

          }
        });
      },

      _loadPostObservers: function () {
        function clearCodings() {
          $$('.coding_state_checkbox').each(function(checkbox) {
            checkbox.setValue(null);
          });
        }

        Event.stopObserving('state_dash', 'change');
        Event.stopObserving('state_question_mark', 'change');
        $('state_dash').observe('change', function() {
          var state = $F('state_dash');
          $('coding_status').selectedIndex=2;
          clearCodings();
          $('state_dash').setValue(state ? true : false);
        });
        $('state_question_mark').observe('change', function() {
          var state = $F('state_question_mark');
          $('coding_status').selectedIndex=2;
          clearCodings();
          $('state_question_mark').setValue(state ? true : false);
        });
      }
    }
  })
});
