<?php
    function smarty_function_mtentrynumberbyday($args, &$ctx) {
        $current = $ctx->stash('entry');
        if (!$current) {
             return $ctx->error('You used an MTEntryNumberByDay tag outside of the proper context.');
        }
        $blog = $ctx->stash('blog');
        if (!$blog) {
             return;
        }
        $prefix    = $args['prefix'];
        $pad       = $args['zeropad'];
        $always    = $args['always'];
        $blog_id   = $blog->id;
        $ts        = $current->entry_authored_on;
        require_once("MTUtil.php");
        $start_end = start_end_day($ts);
        $arg = array(
            'blog_id'               => $blog_id,
            'current_timestamp'     => $start_end[0],
            'current_timestamp_end' => $start_end[1],
            'sort_by'               => 'created_on',
            'order_by'              => 'ascend'
        );
        $mt = $ctx->mt;
        $entries = $mt->db()->fetch_entries($arg);
        $count = count($entries);
        if ($count === 1) {
            if ($always) {
                $number = ($pad ? sprintf("%0${pad}d", 1) : 1);
                return $prefix . $number;
            } else {
                return '';
            }
        }
        $counter = 0;
        foreach ($entries as $e) {
            $counter++;
            if ( $e->id === $current->id ) {
                $number = ($pad ? sprintf("%0${pad}d", $counter) : $counter);
                if ($counter === 1) {
                    if ($always) {
                        return $prefix . $number;
                    }
                    return '';
                }
                return $prefix . $number;
            }
        }
        return '';
    }
?>