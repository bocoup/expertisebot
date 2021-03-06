/*
* Creates a parent command "admin" and passes the sub-commands
*/
import {createCommand} from 'chatter';

// import Sub-commands
import categoryList from './admin/category-list';
import categoryInfo from './admin/category-info';
import categoryAdd from './admin/category-add';
import categoryUpdate from './admin/category-update';
import {categoryEnable, categoryDisable} from './admin/category-enable-disable';

export default createCommand({
  name: 'admin',
  description: 'Admin commands',
}, [
  categoryList,
  categoryInfo,
  categoryAdd,
  categoryUpdate,
  categoryEnable,
  categoryDisable,
]);
