#include "ui.h"

/** Initialize the user interface. */
void ui_init(void) {
    // Test the customized demo 
    //1. Get the whole screen of the device
    lv_obj_t * scr = lv_screen_active();
    //2. Create a new object on the screen
    lv_obj_t * demo = lv_obj_create(scr);
    //3. Create a button
    lv_obj_t * btn = lv_button_create(demo);
    //4. Set the button size and position
    lv_obj_set_size(btn, 100, 50);
    lv_obj_align(btn, LV_ALIGN_CENTER, 0, 0); 
}