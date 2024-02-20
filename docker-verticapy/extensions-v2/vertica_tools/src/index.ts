import {
  ILabShell,
  JupyterFrontEnd,
  JupyterFrontEndPlugin
} from '@jupyterlab/application';
import { ILauncher, LauncherModel as JupyterLauncherModel } from '@jupyterlab/launcher';

import { ICommandPalette, MainAreaWidget } from '@jupyterlab/apputils';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { ITranslator } from '@jupyterlab/translation';
import { launcherIcon, addIcon } from '@jupyterlab/ui-components';

import { toArray } from '@lumino/algorithm';
import { Widget } from '@lumino/widgets';

import { Launcher } from './launcher';
import { verticapyIcon, queryIcon } from './icon'

namespace CommandIDs {
  export const createNew = 'launcher:create';
  export const openConnect = "launcher:connect";
  export const openQprof = "launcher:qprof";
}

const extension: JupyterFrontEndPlugin<ILauncher> = {
  id: 'vertica_launcher:plugin',
  description: 'A custom launcher for vertica extensions.',
  autoStart: true,
  requires: [ITranslator, ILabShell, IMainMenu],
  optional: [ICommandPalette],
  provides: ILauncher,
  activate: (
    app: JupyterFrontEnd,
    translator: ITranslator,
    labShell: ILabShell,
    mainMenu: IMainMenu,
    palette: ICommandPalette | null
  ): ILauncher => {
    const { commands } = app;
    const command = CommandIDs.createNew;

    const trans = translator.load('jupyterlab');
    const model = new JupyterLauncherModel();

    commands.addCommand(command, {
      label: trans.__('New Launcher'),
      icon: addIcon,
      execute: async args => {
        const cwd = args['cwd'] ? String(args['cwd']) : '';
        const id = `launcher-${Private.id++}`;
        const callback = (item: Widget): void => {
          labShell.add(item, 'main', { ref: id });
        };

        const launcher = new Launcher({
          model,
          cwd,
          callback,
          commands,
          translator
        });

        launcher.model = model;
        launcher.title.icon = launcherIcon;
        launcher.title.label = trans.__('Launcher');

        const main = new MainAreaWidget({ content: launcher });

        // If there are any other widgets open, remove the launcher close icon.
        main.title.closable = !!toArray(labShell.widgets('main')).length;
        main.id = id;

        labShell.add(main, 'main', { activate: args['activate'] as boolean });

        labShell.layoutModified.connect(() => {
          // If there is only a launcher open, remove the close icon.
          main.title.closable = toArray(labShell.widgets('main')).length > 1;
        }, main);

        return main;
      }
    });

    commands.addCommand(CommandIDs.openConnect, {
      label: 'Connect',
      icon: verticapyIcon,
      execute: (args: any) => {
        window.open('/voila/render/ui/conn.ipynb?', '_blank');
      }
    });

    commands.addCommand(CommandIDs.openQprof, {
      label: 'Query Profiler',
      icon: queryIcon,
      execute: (args: any) => {
        window.open('/voila/render/ui/qprof_main.ipynb?', '_blank');
      }
    });

    // Add the command to the palette
    if (palette) {
      palette.addItem({
        command,
        category: trans.__('Launcher')
      });
    }

    model.add({
      command: CommandIDs.openConnect,
      category: 'VerticaPy UI',
      rank: 1
    });

    model.add({
      command: CommandIDs.openQprof,
      category: 'VerticaPy UI',
      rank: 2
    });

    return model;

  }
};

/**
 * The namespace for module private data.
 */
namespace Private {
  /**
   * The incrementing id used for launcher widgets.
   */
  // eslint-disable-next-line
  export let id = 0;
}

export default extension;
