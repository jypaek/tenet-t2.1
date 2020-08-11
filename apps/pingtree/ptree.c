/*
* "Copyright (c) 2006~2007 University of Southern California.
* All rights reserved.
*
* Permission to use, copy, modify, and distribute this software and its
* documentation for any purpose, without fee, and without written
* agreement is hereby granted, provided that the above copyright
* notice, the following two paragraphs and the author appear in all
* copies of this software.
*
* IN NO EVENT SHALL THE UNIVERSITY OF SOUTHERN CALIFORNIA BE LIABLE TO
* ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
* DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
* DOCUMENTATION, EVEN IF THE UNIVERSITY OF SOUTHERN CALIFORNIA HAS BEEN
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* THE UNIVERSITY OF SOUTHERN CALIFORNIA SPECIFICALLY DISCLAIMS ANY
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE
* PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
* SOUTHERN CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE,
* SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
*
*/

/**
 * A simple forest (multi-root-tree) data structure.
 *
 * @author Jeongyeup Paek
 * Embedded Networks Laboratory, University of Southern California
 * @modified 2/5/2007
 **/

#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include "ptree.h"

typedef struct pnode_s pnode_t;

struct pnode_s {
    pnode_t *parent;
    pnode_t *next;
    pnode_t *children;
    int id;
    int flag;
    int parent_linkquality;
};


int num_nodes;
int num_all;
int num_roots;
pnode_t *rootlist;
int indent;

pnode_t *rem_rootlist(pnode_t **n);
pnode_t *add_rootlist(pnode_t *n);
pnode_t *find_tree(pnode_t *root, int id);
pnode_t *find_forest(int id);
void link_pedge(pnode_t *p, pnode_t *c);
pnode_t *new_pnode(int id, int flag);



void remove_rootlist(pnode_t *n) {
    pnode_t *t;

    if (n == NULL)
        return;
        
    if (rootlist == n) {
        rootlist = n->next;
        n->next = NULL;
        #ifdef DEBUG
            printf("remove from rootlist %d\n", n->id);
        #endif
        return;
    }
    if (rootlist == NULL)
        return;
    
    for (t = rootlist; t->next; t = t->next) {
        if (t->next == n) {
            t->next = n->next;
            n->next = NULL;
            #ifdef DEBUG
                printf("remove from rootlist %d\n", n->id);
            #endif
            return;
        }
    }            
}

pnode_t *add_rootlist(pnode_t *n) {
    n->next = rootlist;
    rootlist = n;
    num_roots++;
    #ifdef DEBUG
        printf("add to rootlist %d (tot %d)\n", n->id, num_roots);
    #endif
    return n;
}

pnode_t *find_tree(pnode_t *root, int id) {
    pnode_t *n, *r;
    if (root == NULL)
        return NULL;
    if (root->id == id)
        return root;
    for (r = root->children; r; r = r->next) {
        n = find_tree(r, id);
        if (n != NULL)
            return n;
    }
    return NULL;
}

pnode_t *find_forest(int id) {
    pnode_t *r, *n;
    for (r = rootlist; r; r = r->next) {
        n = find_tree(r, id);
        if (n != NULL) {
            #ifdef DEBUG
                printf("found %d \n", n->id);
            #endif
            return n;
        }
    }
    return NULL;
}

void add_ptree_edge(int p_id, int c_id) {
    pnode_t *p, *c;

    #ifdef DEBUG
        printf("add_edge %d -> %d\n", p_id, c_id);
    #endif
    p = find_forest(p_id);
    c = find_forest(c_id);

    if ((p != NULL) && (c != NULL) && (c->parent != NULL) && (c->parent != p)) {
        num_nodes++;
        printf("Warning - duplicate response (child->parent): now %d->%d. ", c_id, p_id);
        printf("It was %d->%d.\n",c_id,c->parent->id);
        printf("but we also got %d->%d\n", c_id, p_id);
        return;
    } else if ((p == NULL) || (c == NULL))
        num_nodes++;

    if (p == NULL) {
        p = new_pnode(p_id, 0);
        add_rootlist(p);
    }
    if (c == NULL) {
        c = new_pnode(c_id, 0);
    } else {
        remove_rootlist(c);
    }
    if (c->parent != p)
        link_pedge(p, c);
}

pnode_t *new_pnode(int id, int flag) {
    pnode_t *t;
    t = malloc(sizeof *t);
    t->id = id;
    t->flag = flag;
    t->parent = NULL;
    t->next = NULL;
    t->children = NULL;
    num_all++;
    return t;
}

void link_pedge(pnode_t *p, pnode_t *c) {
    pnode_t *t;
    if ((p == NULL) || (c == NULL)) {
        printf("Ooops \n");
        exit(0);
    }
    c->parent = p;

    if (p->children && (c->id > p->children->id)) {
        t = p->children;
        while (t->next && (c->id > t->next->id)) {
            t = t->next;
        }
        c->next = t->next;
        t->next = c;
    } else {
        c->next = p->children;
        p->children = c;
    }
}

void set_link_quality(int n1, int n2, int q) {
    pnode_t *p, *c;

    c = find_forest(n1);
    p = find_forest(n2);

    if ((p == NULL) || (c == NULL) || (c->parent != p)) {
      printf("Could not find the link: %d->%d\n", n1, n2);
      return;
    }
    
    c->parent_linkquality = q;
}


void print_tree(pnode_t *root, int link_quality) {
    pnode_t *r;
    if (root == NULL)
        return;
    //printf("%*s %d\n", indent, "", root->id);
    for (r = root->children; r; r = r->next) {
        if (link_quality == 1) {
            printf("%*s \\--- %3d --- (%d)\n", indent, "", r->parent_linkquality, r->id);
        } else {
            printf("%*s \\--- %d\n", indent, "", r->id);
        }
        indent += link_quality == 0? 6 : 15;
        print_tree(r, link_quality);
        indent -= link_quality == 0? 6 : 15;
    }
}

void print_forest(int link_quality) {
    pnode_t *r;
    if (rootlist == NULL)
        return;
    for (r = rootlist; r; r = r->next) {
        printf("%*s[%3d]\n", indent, "", r->id);
        indent += 5;
        print_tree(r, link_quality);
        indent -= 5;
        printf("\n");
    }
}

void print_ptree(int link_quality) {
    indent = 2;
    printf("\n\n < Printing the forest > ");
    printf("  (num_nodes %d, num_all %d)\n\n", 
                num_nodes, num_all);
    print_forest(link_quality);
}

void print_treeDotFormat(FILE *in, pnode_t *root, int link_quality) {
    pnode_t *r;
    if (root == NULL)
        return;
    for (r = root->children; r; r = r->next) {
        if (link_quality == 1) {
            fprintf(in,"%d -> %d [label=\"%d\"];\n", r->id, root->id, r->parent_linkquality);
        } else {
            fprintf(in,"%d -> %d;\n", r->id, root->id);
        }
        print_tree(r, link_quality);
    }
}

void print_forestDotFormat(FILE *in,int link_quality) {
    pnode_t *r;
    if (rootlist == NULL)  return;
    for (r = rootlist; r; r = r->next) {
        print_treeDotFormat(in,r, link_quality);
    }
}

/**
 * Create a .dot file that can be used to generate a topology figure.
 * Use command:
 *    $dot -Tps -o pingtree.ps pingtree.dot
 * to generate figure 'pingtree.ps' from .dot file 'pintree.dot'
 **/
void print_ptreeDotFormat(FILE *in,int link_quality) {
    fprintf(in,"\n//to draw: $ dot -Tps filename.dot -o filename.ps\n");
    fprintf(in,"\ndigraph G {\n");
    fprintf(in,"  node [shape=circle, style=filled, color=\".7 .3 1.0\"];\n");
    print_forestDotFormat(in,link_quality);
    fprintf(in,"}\n");
}

void delete_pnode(pnode_t *r) {
    pnode_t *dead = r;
    if (dead == NULL)
        return;
    #ifdef DEBUG
        printf("remove %d \n", dead->id);
    #endif
    free(dead);
}

void remove_tree(pnode_t *root) {
    pnode_t *r, *dead;
    if (root == NULL)
        return;
    for (r = root->children; r; ) {
        remove_tree(r);
        dead = r;
        r = r->next;
        delete_pnode(dead);
    }
}

void delete_ptree() {
    pnode_t *r, *dead;
    for (r = rootlist; r; ) {
        remove_tree(r);
        dead = r;
        r = r->next;
        delete_pnode(dead);
    }
}

