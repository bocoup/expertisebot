/*
* Creates a parent command "admin" and passes the sub-commands
*/
import {createCommand} from 'chatter';

// import Sub-commands
import addCategory from './admin/add-category';
import updateCategory from './admin/update-category';
import activateCategory from './admin/activate-category';
import deactivateCategory from './admin/deactivate-category';

export default createCommand({
  name: 'admin',
  description: 'Admin commands',
}, [
  addCategory,
  updateCategory,
  activateCategory,
  deactivateCategory,
]);