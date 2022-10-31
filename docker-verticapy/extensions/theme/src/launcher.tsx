import {
    Launcher as JupyterlabLauncher,
    LauncherModel as JupyterLauncherModel,
    ILauncher
} from '@jupyterlab/launcher';
import { TranslationBundle } from '@jupyterlab/translation';
import { LabIcon } from '@jupyterlab/ui-components';

import { ArrayIterator, each, IIterator } from '@lumino/algorithm';

import * as React from 'react';
import verticaIconSvg from '../style/icons/vertica2.svg';

export const verticaIcon = new LabIcon({
    name: 'vertica:vertica',
    svgstr: verticaIconSvg
  });
const CommandIDs = {
    open: 'inspector:open',
    createNew: 'terminal:create-new'
  };
/**
 * The known categories of launcher items and their default ordering.
 */
const VERTICA_CATEGORY = 'Vertica';
const VERTICAPY_LESSONS = 'VerticaPy Lessons';

export class LauncherModel extends JupyterLauncherModel {
    /**
     * Return an iterator of launcher items, but remove unnecessary items.
     */
    items(): IIterator<ILauncher.IItemOptions> {
      const items: ILauncher.IItemOptions[] = [];
  
      // Change terminal category and don't add the inspector
      this.itemsList.forEach(item => {
        if(item.command === CommandIDs.createNew) {
            item.category = 'Console';
            item.rank = 1;
        }
        if(item.command !== CommandIDs.open) {
            items.push(item);
        }
      });
  
      return new ArrayIterator(items);
    }
  }
  
export class Launcher extends JupyterlabLauncher {
    /**
     * Construct a new launcher widget.
     */
    constructor(options: ILauncher.IOptions) {
        super(options);
        this._translator = this.translator.load('jupyterlab');
    }

    private replaceCategoryIcon(
        category: React.ReactElement,
        icon: LabIcon
    ): React.ReactElement {
        const children = React.Children.map(category.props.children, child => {
        if (child.props.className === 'jp-Launcher-sectionHeader') {
            const grandchildren = React.Children.map(
            child.props.children,
            grandchild => {
                if (grandchild.props.className !== 'jp-Launcher-sectionTitle') {
                return <icon.react stylesheet="launcherSection" />;
                } else {
                return grandchild;
                }
            }
            );

            return React.cloneElement(child, child.props, grandchildren);
        } else {
            return child;
        }
        });

        return React.cloneElement(category, category.props, children);
    }

    /**
     * Render the launcher to virtual DOM nodes.
     */
    protected render(): React.ReactElement<any> | null {
        // Bail if there is no model.
        if (!this.model) {
        return null;
        }

        // get the rendering from JupyterLab Launcher
        // and resort the categories
        const launcherBody = super.render();
        const launcherContent = launcherBody?.props.children;
        const launcherCategories = launcherContent.props.children;

        const categories: React.ReactElement<any>[] = [];

        const knownCategories = [
        VERTICA_CATEGORY,
        VERTICAPY_LESSONS,
        this._translator.__('Notebook'),
        this._translator.__('Console'),
        this._translator.__('Other')
        ];

        // Assemble the final ordered list of categories
        // based on knownCategories.
        each(knownCategories, (category, index) => {
        React.Children.forEach(launcherCategories, cat => {
            if (cat.key === category) {
            if (cat.key === VERTICA_CATEGORY) {
                cat = this.replaceCategoryIcon(cat, verticaIcon);
            }
            if (cat.key === VERTICAPY_LESSONS) {
                cat = this.replaceCategoryIcon(cat, verticaIcon);
            } 
            categories.push(cat);
            }
        });
        });

        // Wrap the sections in body and content divs.
        return (
        <div className="jp-Launcher-body">
            <div className="jp-Launcher-content">
            <div className="jp-Launcher-cwd">
                <h3>{this.cwd}</h3>
            </div>
            {categories}
            </div>
        </div>
        );
    }

    private _translator: TranslationBundle;
}
